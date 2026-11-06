// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_unstructured_io/otel_unstructured_io.dart';

/// Traces Unstructured.io calls with OpenTelemetry.
///
/// `otel_unstructured_io` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Unstructured.io call in
/// [tracedUnstructuredIo]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'unstructured-io-example');

  // Wraps an Unstructured.io API call in a CLIENT span.
  final unstructuredIoId = await tracedUnstructuredIo<String>(
    operation: 'workflows.create',
    invoke: () async {
      // Make the Unstructured.io call here, then report what it returned.
      const id = 'unstructured_io_8f3a2c';
      return const UnstructuredIoCallResult(
          value: id,
          result: UnstructuredIoResult(
              serverlessTier: 'free',
              filename: 'example',
              mimeType: 'application/pdf',
              fileSizeBytes: 512,
              strategy: 'auto',
              pdfInferTableStructure: true,
              languages: 'eng,fra',
              chunkingStrategy: 'by_title',
              maxCharacters: 1,
              overlap: 1,
              pagesProcessed: 1,
              elementsReturned: 1,
              tableElements: 1,
              imageElements: 1,
              workflowId: 'workflow_8f3a2c',
              jobId: 'job_8f3a2c',
              jobStatus: 'created',
              statusCode: 201));
    },
  );
  OTelLog.info(
      'tracedUnstructuredIo workflows.create returned $unstructuredIoId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutUnstructuredIoInstrumentationAsync.
  await runWithoutUnstructuredIoInstrumentationAsync(
    () => tracedUnstructuredIo<String>(
      operation: 'workflows.create',
      invoke: () async {
        const id = 'unstructured_io_8f3a2c';
        return const UnstructuredIoCallResult(
            value: id,
            result: UnstructuredIoResult(
                serverlessTier: 'free',
                filename: 'example',
                mimeType: 'application/pdf',
                fileSizeBytes: 512,
                strategy: 'auto',
                pdfInferTableStructure: true,
                languages: 'eng,fra',
                chunkingStrategy: 'by_title',
                maxCharacters: 1,
                overlap: 1,
                pagesProcessed: 1,
                elementsReturned: 1,
                tableElements: 1,
                imageElements: 1,
                workflowId: 'workflow_8f3a2c',
                jobId: 'job_8f3a2c',
                jobStatus: 'created',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
