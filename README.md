# CFML PDF to Image Example


Example using [PDFBox](https://pdfbox.apache.org/) to convert PDF pages to images in CFML (concurrently).

> Requires ColdFusion 2021 / Lucee 5.x+, but the IIFE in the example can be broken out to a function/lambda expression to support ColdFusion 2018.

## Installation

### CommandBox

[CommandBox](https://www.ortussolutions.com/products/commandbox) is the recommended way to run this project's examples.

Launch a terminal pointing at the project root and run `box` to get CommandBox going. Then run `install && start` to pull in the Java dependencies and start the server instance. By default the latest available flavor of Lucee will be used. To switch engines, you may pass in the `cfengine` parameter to CommandBox or update `server.json` in the project root.

### Manual

A list of Java dependencies can be found in `box.json`. Follow the JAR links to manually download the required dependencies. Place those files in `/lib` of the project root. From there you can run the project using the engine of your choice.
