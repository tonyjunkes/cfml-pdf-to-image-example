component displayname="PDF Service"
    output=false
{
    /**
     * @hint Constructor
     */
    public PDFService function init() {
        return this;
    }

    /**
     * @hint Converts pages of a binary PDF document into binary JPG images.
     * @pdfFile.hint A binary representation of the file to be converted.
     */
    public array function pdfToImage(binary pdfFile) {
        var result = [];
        // Collection for async processes
        var futures = [];

        try {
            var ByteArrayOutputStream = createObject("java", "java.io.ByteArrayOutputStream");
            var ImageIO = createObject("java", "javax.imageio.ImageIO");
            var PDFRenderer = createObject("java", "org.apache.pdfbox.rendering.PDFRenderer");
            var PDDocument = createObject("java", "org.apache.pdfbox.pdmodel.PDDocument");

            // Get the page tree iterator from the document
            var pageTreeDocument = PDDocument.load(arguments.pdfFile);
            var pageTree = pageTreeDocument.getDocumentCatalog().getPages();
            var pageIterator = pageTree.iterator();

            // Process pages
            while (pageIterator.hasNext()) {
                var currentPage = pageIterator.next();
                var pageIndex = pageTree.indexOf(currentPage);
                // Note: PDFBox is not thread safe!
                // A new instance of the PDF is created for each thread
                var threadDocument = PDDocument.load(arguments.pdfFile);

                // Collect each future worker
                futures.append(
                    ((document, index) => {
                        return runAsync(() => {
                            try {
                                // Convert page to BufferedImage
                                var renderer = PDFRenderer.init(document);
                                var pageImage = renderer.renderImage(index);
                                // Write as JPG to OutputStream
                                var imageOS = ByteArrayOutputStream.init();
                                ImageIO.write(pageImage, "jpg", imageOS);
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
            pageTreeDocument?.close();
            threadDocument?.close();
        }

        return result;
    }
}