// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_unstructured_io/otel_unstructured_io.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_unstructured_io-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('partition records strategy + pages + element breakdown', () async {
    await tracedUnstructuredIo<String>(
      operation: 'partition',
      invoke: () async => const UnstructuredIoCallResult(
        value: 'ok',
        result: UnstructuredIoResult(
          serverlessTier: 'serverless',
          filename: 'q4-report.pdf',
          mimeType: 'application/pdf',
          fileSizeBytes: 1245000,
          strategy: 'hi_res',
          pdfInferTableStructure: true,
          languages: 'eng',
          pagesProcessed: 24,
          elementsReturned: 188,
          tableElements: 7,
          imageElements: 12,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('unstructured_io partition')!);
    expect(a['unstructured_io.tier'], 'serverless');
    expect(a['unstructured_io.strategy'], 'hi_res');
    expect(a['unstructured_io.pdf.infer_table_structure'], true);
    expect(a['unstructured_io.pages.processed'], 24);
    expect(a['unstructured_io.elements.tables'], 7);
  });

  test('jobs.get failed status sets span error', () async {
    await tracedUnstructuredIo<String>(
      operation: 'jobs.get',
      invoke: () async => const UnstructuredIoCallResult(
        value: 'ok',
        result: UnstructuredIoResult(
          workflowId: 'wf_1',
          jobId: 'job_1',
          jobStatus: 'failed',
        ),
      ),
    );
    expect(
      spans.findSpanByName('unstructured_io jobs.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('partition.chunked records chunking strategy', () async {
    await tracedUnstructuredIo<String>(
      operation: 'partition.chunked',
      invoke: () async => const UnstructuredIoCallResult(
        value: 'ok',
        result: UnstructuredIoResult(
          strategy: 'fast',
          chunkingStrategy: 'by_title',
          maxCharacters: 1500,
          overlap: 100,
          pagesProcessed: 5,
          elementsReturned: 42,
          statusCode: 200,
        ),
      ),
    );
    final a =
        attrsOf(spans.findSpanByName('unstructured_io partition.chunked')!);
    expect(a['unstructured_io.chunking.strategy'], 'by_title');
    expect(a['unstructured_io.chunking.max_characters'], 1500);
    expect(a['unstructured_io.chunking.overlap'], 100);
  });

  test('suppression skips spans', () async {
    await runWithoutUnstructuredIoInstrumentationAsync(() async {
      await tracedUnstructuredIo<String>(
        operation: 'workflows.run',
        invoke: () async => const UnstructuredIoCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('unstructured_io '), isEmpty);
  });
}
