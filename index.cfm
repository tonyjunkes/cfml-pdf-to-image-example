<h1>CFML PDF to Image Example</h1>

<!--- File conversion --->
<cfscript>
    PDFService = new components.PDFService();
    pdfFile = fileReadBinary(expandPath("/resources/sample.pdf"));
    pages = PDFService.pdfToImage(pdfFile = pdfFile);
</cfscript>

<!--- Draw results to screen --->
<cfloop array="#pages#" item="page" index="index">
    <cfoutput>
        <img src="data:image/jpg;base64,#binaryEncode(page, "base64")#" alt="Page #index#" />
    </cfoutput>
</cfloop>