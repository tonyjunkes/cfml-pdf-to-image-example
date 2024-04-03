component displayname="PDF Service"
	output=false
{
	/**
	 * Constructor
	 */
	public PDFService function init() {
		return this;
	}

	/**
	 * Converts pages of a binary PDF document into binary JPG images.
	 * @pdfFile A binary representation of the file to be converted.
	 * @imageFormat The file format of the images being generated (e.g. GIF, PNG, JPG, etc.).
	 * @pageStart The page to start processing at.
	 * @pageLimit The number of pages to process in the PDF. Defaults to total number of pages when null or <1.
	 */
	public array function pdfToImage(
		required binary pdfFile,
		string imageFormat = "jpg",
		numeric pageStart = 1,
		numeric pageLimit
	) {
		var result = [];

		try {
			var ByteArrayOutputStream = createObject("java", "java.io.ByteArrayOutputStream");
			var ImageIO = createObject("java", "javax.imageio.ImageIO");
			var Loader = createObject("java", "org.apache.pdfbox.Loader");
			var PDFRenderer = createObject("java", "org.apache.pdfbox.rendering.PDFRenderer");
			var PDDocument = createObject("java", "org.apache.pdfbox.pdmodel.PDDocument");

			// Load document as a PDDocument
			var mainDocument = Loader.loadPDF(arguments.pdfFile);
			var pageCount = mainDocument.getNumberOfPages();

			// Verify pageStart is within the total number of document pages
			if (arguments.pageStart <= 0 || arguments.pageStart > pageCount) {
				throw("The [pageStart] value #arguments.pageStart# is out of bounds. Total number of pages is #pageCount#.");
			}

			// When pageLimit evaluates as falsy, default pageLimit to total number of document pages
			if (arguments?.pageLimit < 1) arguments.pageLimit = pageCount;

			// Process pages concurrently
			// Note: Page index of PDDocument is 0-based
			var futures = [];
			var pageCounter = 1;

			for (var pageIndex = --arguments.pageStart; pageIndex < pageCount; pageIndex++) {
				// Break out of processing if page limit reached
				if (pageCounter > arguments.pageLimit) break;
				// Increase counter to maintain page limit threshold
				pageCounter++;
				// Note: PDFBox is not thread safe!
				// A new instance of the PDF is created for each thread
				var threadDocument = Loader.loadPDF(arguments.pdfFile);

				// Collect each future worker
				futures.append(
					((document, index) => {
						return runAsync(() => {
							try {
								// Convert page to BufferedImage
								var renderer = PDFRenderer.init(document);
								var pageImage = renderer.renderImage(index);
								// Write image format to OutputStream
								var imageOS = ByteArrayOutputStream.init();
								ImageIO.write(pageImage, imageFormat, imageOS);
								// Add results to collection to be sorted later
								return { index: index, image: imageOS.toByteArray() };
							}
							catch(any e) {
								rethrow;
							}
							finally {
								// Close streams
								document?.close();
								imageOS?.close();
							}
						});
					})(threadDocument, pageIndex)
				);
			}

			// Block (await) any further processing until each future has completed
			// Sort pages back to original order and return the images
			result = futures
				.map((future) => arguments.future.get())
				.sort((page1, page2) => arguments.page1.index - arguments.page2.index)
				.map((page) => arguments.page.image);
		}
		catch(any e) {
			// For debugging the example, don't use in production!
			writeDump(e);
		}
		finally {
			// Close streams
			mainDocument?.close();
			threadDocument?.close();
		}

		return result;
	}

	/**
	 * Converts a collection of images to a PDF (one image per page) and writes to the path provided.
	 * Note: This example makes the assumption the images are formated for an A4/Letter style PDF.
	 * The images are still scaled in an attempt to maintain image quality.
	 * @images A collection of binary images to be converted.
	 * @outputFile The location and name of the resulting PDF.
	 */
	public void function imagesToPDF(
		required array images,
		required string outputFile
	) {
		try {
			var PDDocument = createObject("java", "org.apache.pdfbox.pdmodel.PDDocument");
			var PDPage = createObject("java", "org.apache.pdfbox.pdmodel.PDPage");
			var PDImageXObject = createObject("java", "org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject");
			var PDPageContentStream = createObject("java", "org.apache.pdfbox.pdmodel.PDPageContentStream");

			// Create the directory if it doesn't exist
			var filePath = getDirectoryFromPath(arguments.outputFile);
			if (!directoryExists(filePath)) directoryCreate(filePath);

			// Create the PDF document
			var document = PDDocument.init();

			// Add each image to a new page
			for (var image in arguments.images) {
				// Create a new page
				var page = PDPage.init();
				document.addPage(page);

				// Add the image to the page
				var contentStream = PDPageContentStream.init(document, page);
				var ximage = PDImageXObject.createFromByteArray(document, image, "");

				// Calculate the scale to fit the image on the page if necessary
				var scaleX = page.getMediaBox().getWidth() / ximage.getWidth();
				var scaleY = page.getMediaBox().getHeight() / ximage.getHeight();
				var scale = min(scaleX, scaleY);

				// Draw the image
				contentStream.drawImage(ximage, 0, 0, ximage.getWidth() * scale, ximage.getHeight() * scale);
				contentStream.close();
			}

			// Save the document
			document.save(arguments.outputFile);
		}
		catch(any e) {
			// For debugging the example, don't use in production!
			writeDump(e);
		}
		finally {
			// Close streams
			document?.close();
			contentStream?.close();
		}
	}
}