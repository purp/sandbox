
// Highlighting tricks from http://www.nsftools.com/misc/SearchAndHighlight.htm
// Heavily modified to do regexes
function doHighlight(searchTerm, withNav) 
{
  var bodyText = document.body.innerHTML;

  highlightStartTag = "<a id='found_IDX' class='highlighted_term' name='found_IDX'><font style='color:blue; background-color:yellow;'>";
  highlightEndTag = "</font></a>";
  
  // TODO: Find any non-(?: captures and change them to (?:
  var searchRegExp = new RegExp("(" + searchTerm + ")", "gi");
  var elements = bodyText.split(searchRegExp);
  
  for (idx in elements) {
    prev_idx = +idx - 2;
    next_idx = +idx + 2;
    
    if (searchRegExp.test(elements[idx])) {
      elements[idx] = highlightStartTag.replace(/IDX/, idx) + elements[idx] + highlightEndTag;
      if (withNav) {
        if (prev_idx > 0) {
          elements[idx] = "<a href='#found_" + prev_idx + "'>«</a>" + elements[idx];
        }
        if (next_idx < elements.length) {
          elements[idx] += "<a href='#found_" + (+idx + 2) + "'>»</a>";
        }
      }
    }
  }
  
  setInnerHTML(document.body, elements.join(""));

  if (withNav) {
    // insert nav div
    navdiv = document.createElement('div');
    document.body.adoptNode(navdiv);
  }
}

// FF doesn't like it when you assign to body.innerHTML on a non-HTML page, but you can fool it.
// From http://stackoverflow.com/questions/740156/how-to-use-innerhtml-on-plain-txt-files-in-firefox

var setInnerHTML = function(el, string) {
    // element.innerHTML does not work on plain text files in FF; this restriction is similar to
    // http://groups.google.com/group/mozilla.dev.extensions/t/55662db3ea44a198
    var self = arguments.callee;
    if (typeof self.supportsInnerHTML == 'undefined') {
        var testParent = document.createElement('div');
        testParent.innerHTML = '<p/>';
        self.supportsInnerHTML = (testParent.firstChild.nodeType == 1);
    }
    if (self.supportsInnerHTML) {
        el.innerHTML = string;
        return el;
    } else if (typeof XSLTProcessor == 'undefined') {
        return undefined;
    } else {
        if (typeof self.cleanDocument == 'undefined')
            self.cleanDocument = createHTMLDocument();

        if (el.parentNode) {
            var cleanEl = self.cleanDocument.importNode(el, false);
            cleanEl.innerHTML = string;
            el.parentNode.replaceChild(document.adoptNode(cleanEl), el);
        } else {
            var cleanEl = self.cleanDocument.adoptNode(el);
            cleanEl.innerHTML = string;
            el = document.adoptNode(cleanEl);
        }

        return el;
    }

    function createHTMLDocument() {
        // Firefox does not support document.implementation.createHTMLDocument()
        // cf. http://www.quirksmode.org/dom/w3c_html.html#t12
        // the following is taken from http://gist.github.com/49453
        var xmlDoc = document.implementation.createDocument('', 'fooblar', null);
        var templ = '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">'
                + '<xsl:output method="html"/><xsl:template match="/">'
                + '<html><title/><body/></html>'
                + '</xsl:template></xsl:stylesheet>';
        var proc = new XSLTProcessor();
        proc.importStylesheet(new DOMParser().parseFromString(templ,'text/xml'));
        return proc.transformToDocument(xmlDoc);
    }
};

alert('thljs');