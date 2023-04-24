<h1>CFML PDF to Image Example</h1>

<!--- File conversion --->
<cfscript>
    PDFService = new components.PDFService();
    pdfFile = fileReadBinary(expandPath("/resources/sample.pdf"));
    pages = PDFService.pdfToImage(pdfFile = pdfFile, imageFormat = "jpg");
</cfscript>

<!--- Render Example 1 --->
<h2>Render First 3 Pages</h2>
<cfset pages = PDFService.pdfToImage(pdfFile = pdfFile, imageFormat = "jpg", pageLimit = 3)>
<cfloop array="#pages#" item="page" index="index">
    <cfoutput>
        <h3>Page #index#</h3>
        <img src="data:image/jpg;base64,#binaryEncode(page, "base64")#" alt="Page #index#" />
    </cfoutput>
</cfloop>

<!--- Render Example 2 --->
<h2>Render Starting At Page 3 &amp; Stop After the 2nd Page</h2>
<cfset pages = PDFService.pdfToImage(pdfFile = pdfFile, imageFormat = "jpg", pageStart = 3, pageLimit = 2)>
<cfloop array="#pages#" item="page" index="index">
    <cfoutput>
        <h3>Page #index#</h3>
        <img src="data:image/jpg;base64,#binaryEncode(page, "base64")#" alt="Page #index#" />
    </cfoutput>
</cfloop>

<!--- Render Example 3 --->
<h2>Render All Pages</h2>
<cfset pages = PDFService.pdfToImage(pdfFile = pdfFile, imageFormat = "jpg")>
<cfloop array="#pages#" item="page" index="index">
    <cfoutput>
        <h3>Page #index#</h3>
        <img src="data:image/jpg;base64,#binaryEncode(page, "base64")#" alt="Page #index#" />
    </cfoutput>
</cfloop>