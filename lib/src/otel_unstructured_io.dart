// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_unstructured_io_suppression.dart';

const _tracerName = 'dartastic_otel_libs_unstructured_io';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class UnstructuredIoResult {
  /// Creates a result.
  const UnstructuredIoResult({
    this.serverlessTier,
    this.filename,
    this.mimeType,
    this.fileSizeBytes,
    this.strategy,
    this.pdfInferTableStructure,
    this.languages,
    this.chunkingStrategy,
    this.maxCharacters,
    this.overlap,
    this.pagesProcessed,
    this.elementsReturned,
    this.tableElements,
    this.imageElements,
    this.workflowId,
    this.jobId,
    this.jobStatus,
    this.statusCode,
  });

  /// `free` / `serverless` / `paid` — Unstructured.io's billing tiers
  /// (the strategy/availability + per-page price differ).
  final String? serverlessTier;

  final String? filename;

  /// `application/pdf` / `application/msword` / `text/html` / etc.
  final String? mimeType;

  final int? fileSizeBytes;

  /// `auto` / `fast` / `hi_res` / `ocr_only` / `vlm` — partition
  /// strategy (hi_res / vlm are the most expensive).
  final String? strategy;

  /// `true` when PDF table structure inference was requested.
  final bool? pdfInferTableStructure;

  /// Comma-separated language hints (e.g., `eng,fra`).
  final String? languages;

  /// `by_title` / `basic` / `by_page` / `by_similarity` — chunking
  /// strategy when called via the chunking API.
  final String? chunkingStrategy;

  final int? maxCharacters;
  final int? overlap;

  /// Pages processed (Unstructured bills per page for hi_res/vlm).
  final int? pagesProcessed;

  /// Total elements (`NarrativeText` / `Title` / `ListItem` / `Table`
  /// / `Image` / `Header` / `Footer` / `Address` / `FigureCaption`
  /// / ...).
  final int? elementsReturned;

  /// Subset counts that matter for downstream pipelines.
  final int? tableElements;
  final int? imageElements;

  /// Workflows API ids (the platform's async pipeline product).
  final String? workflowId;
  final String? jobId;

  /// `created` / `scheduled` / `in_progress` / `completed` /
  /// `failed` / `cancelled`.
  final String? jobStatus;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class UnstructuredIoCallResult<T> {
  /// Creates a call result.
  const UnstructuredIoCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final UnstructuredIoResult? result;
}

/// Wraps an Unstructured.io API call in a CLIENT span. [operation] is
/// one of `partition`, `partition.chunked`, `workflows.create`,
/// `workflows.run`, `jobs.get`, `jobs.list`, `jobs.cancel`,
/// `sources.create`, `destinations.create`, `connectors.list`.
Future<T> tracedUnstructuredIo<T>({
  required String operation,
  required Future<UnstructuredIoCallResult<T>> Function() invoke,
}) async {
  if (unstructuredIoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'unstructured_io',
    'rpc.method': operation,
    'unstructured_io.operation': operation,
  };

  final span = _tracer().startSpan(
    'unstructured_io $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.serverlessTier != null) {
        extras.add(OTelAPI.attributeString(
          'unstructured_io.tier',
          r.result!.serverlessTier!,
        ));
      }
      if (r.result!.filename != null) {
        extras.add(OTelAPI.attributeString(
          'unstructured_io.filename',
          r.result!.filename!,
        ));
      }
      if (r.result!.mimeType != null) {
        extras.add(OTelAPI.attributeString(
          'unstructured_io.mime_type',
          r.result!.mimeType!,
        ));
      }
      if (r.result!.fileSizeBytes != null) {
        extras.add(OTelAPI.attributeInt(
          'unstructured_io.file.size_bytes',
          r.result!.fileSizeBytes!,
        ));
      }
      if (r.result!.strategy != null) {
        extras.add(OTelAPI.attributeString(
          'unstructured_io.strategy',
          r.result!.strategy!,
        ));
      }
      if (r.result!.pdfInferTableStructure != null) {
        extras.add(OTelAPI.attributeBool(
          'unstructured_io.pdf.infer_table_structure',
          r.result!.pdfInferTableStructure!,
        ));
      }
      if (r.result!.languages != null) {
        extras.add(OTelAPI.attributeString(
          'unstructured_io.languages',
          r.result!.languages!,
        ));
      }
      if (r.result!.chunkingStrategy != null) {
        extras.add(OTelAPI.attributeString(
          'unstructured_io.chunking.strategy',
          r.result!.chunkingStrategy!,
        ));
      }
      if (r.result!.maxCharacters != null) {
        extras.add(OTelAPI.attributeInt(
          'unstructured_io.chunking.max_characters',
          r.result!.maxCharacters!,
        ));
      }
      if (r.result!.overlap != null) {
        extras.add(OTelAPI.attributeInt(
          'unstructured_io.chunking.overlap',
          r.result!.overlap!,
        ));
      }
      if (r.result!.pagesProcessed != null) {
        extras.add(OTelAPI.attributeInt(
          'unstructured_io.pages.processed',
          r.result!.pagesProcessed!,
        ));
      }
      if (r.result!.elementsReturned != null) {
        extras.add(OTelAPI.attributeInt(
          'unstructured_io.elements.returned',
          r.result!.elementsReturned!,
        ));
      }
      if (r.result!.tableElements != null) {
        extras.add(OTelAPI.attributeInt(
          'unstructured_io.elements.tables',
          r.result!.tableElements!,
        ));
      }
      if (r.result!.imageElements != null) {
        extras.add(OTelAPI.attributeInt(
          'unstructured_io.elements.images',
          r.result!.imageElements!,
        ));
      }
      if (r.result!.workflowId != null) {
        extras.add(OTelAPI.attributeString(
          'unstructured_io.workflow.id',
          r.result!.workflowId!,
        ));
      }
      if (r.result!.jobId != null) {
        extras.add(OTelAPI.attributeString(
          'unstructured_io.job.id',
          r.result!.jobId!,
        ));
      }
      if (r.result!.jobStatus != null) {
        extras.add(OTelAPI.attributeString(
          'unstructured_io.job.status',
          r.result!.jobStatus!,
        ));
        if (r.result!.jobStatus == 'failed') {
          span.setStatus(
            SpanStatusCode.Error,
            'Unstructured job failed',
          );
        }
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Unstructured HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
