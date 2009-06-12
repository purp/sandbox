// ==UserScript==
// @name           Find Java Errors
// @namespace      http://qa.linkedin.com/
// @description    Looks for java.lang..*(Error|Exception) and highlights
// @include        http://*hudson*/job/*/*/consoleText
// @include        http://*hudson*/job/*/*/consoleText#*
// @version        1.0
// ==/UserScript==

var include = function(src) {
  var script = document.createElement("script");
  script.setAttribute("language", "javascript");
  script.setAttribute("src", src);
  body.appendChild(script);
};

// Highlighting tricks from http://www.nsftools.com/misc/SearchAndHighlight.htm
// Heavily modified to do regexes
function doHighlight(searchTerm, withNav) {
  var bodyText = document.body.innerHTML;

  highlightStartTag = "<a id='found_IDX' class='highlighted_term' name='found_IDX'><font style='color:blue; background-color:yellow;'>";
  highlightEndTag = "</font></a>";

  // TODO: catch any paren-captures and ?: escape them
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
    // document.body.adoptNode(navdiv);
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
    if (typeof self.cleanDocument == 'undefined') {
      self.cleanDocument = createHTMLDocument();
    }
    var cleanEl = null;
    if (el.parentNode) {
      cleanEl = self.cleanDocument.importNode(el, false);
      cleanEl.innerHTML = string;
      el.parentNode.replaceChild(document.adoptNode(cleanEl), el);
    } else {
      cleanEl = self.cleanDocument.adoptNode(el);
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
// 
// // Cached from http://www.gerv.net/software/thl/highlight-target.js
// ///////////////////////////////////////////////////////////////////////////////
// //
// // Target Highlighting Library v1.0
// //
// // Copyright (c) 2005 Gervase Markham
// //
// // Permission is hereby granted, free of charge, to any person obtaining a
// // copy of this software and associated documentation files (the "Software"),
// // to deal in the Software without restriction, including without limitation
// // the rights to use, copy, modify, merge, publish, distribute, sublicense,
// // and/or sell copies of the Software, and to permit persons to whom the
// // Software is furnished to do so, subject to the following conditions:
// //
// // The above copyright notice and this permission notice shall be included in
// // all copies or substantial portions of the Software.
// //
// // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// // FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// // DEALINGS IN THE SOFTWARE.
// //
// // Maintainer: gerv@gerv.net; http://www.gerv.net/software/thl/
// //
// // CHANGELOG:
// //
// // v1.0: Fix bug reported in blog by Gary van der Merwe (2005-10-03)
// // v0.1: initial version (2005-09-25)
// //
// ///////////////////////////////////////////////////////////////////////////////
// 
// ///////////////////////////////////////////////////////////////////////////////
// //
// // This library applies a class to the <a> element which was the target, if
// // there was one, of the last link the user clicked.
// //
// // Use the following markup to include the library:
// // <script type="text/javascript" src="highlight-target.js"></script>
// //
// // This library allows for separation of content and presentation. You style
// // the target by styling the class "isTarget".
// //
// // .isTarget { color: red; }
// //
// // This class is applied to the element with the same ID as the anchor. Because
// // names are checked before IDs, you can style a different element to the <a>
// // if you wish:
// // <h1 id="foo">This is a <a name="foo">heading</a></h1>
// //
// ///////////////////////////////////////////////////////////////////////////////
// 
// var currentTarget = null;
// 
// addEvent(window, "load", prepareHighlightTarget);
// 
// function prepareHighlightTarget()
// {
//   if (document.getElementsByTagName)
//   {
//     // Set up a click listener on all links. It would be easier if we could
//     // attach a change listener to location.href, but it seems we can't.
//     var links = document.getElementsByTagName("a");
//     
//     for (var i = 0; i < links.length; i++)
//     {
//       if (links[i].getAttribute("href") != null)
//       {
//         addEvent(links[i], "click", highlightTarget);
//       }
//     }
//     
//     // Highlight any initial target
//     var id = document.location.href.replace(/.*#/, "");
//     if (id)
//     {
//       highlightElement(id);
//     }
//   }
// }
// 
// function highlightTarget(e)
// {
//  if (!e) var e = window.event;
// 
//  var elem;  
//  if (e.target)
//   {
//     elem = e.target;
//   }
//  else if (e.srcElement) 
//   { 
//     elem = e.srcElement;
//   }
//   
//   // Move up the tree until we get to the A
//   while (elem.nodeName != 'A')
//   {
//     elem = elem.parentNode;
//   }
//   
//   var id = elem.getAttribute("href").replace(/.*#/, "");
//   if (id)
//   {
//     highlightElement(id);
//   }
// }
// 
// // This could be rewritten to use generic class add/remove code if you have it
// // function highlightElement(id)
// // {
// //   var theName = "isTarget";
// //   
// //   // Remove class
// //   if (currentTarget)
// //   {
// //     var removeMe = currentTarget.className.match(" " + theName) ? " " : "";
// //     removeMe += theName;
// //     currentTarget.className = currentTarget.className.replace(removeMe, "");
// //   }
// //     
// //   var newTarget = document.getElementById(id);
// //   if (newTarget)
// //   {
// //     // Add class
// //     newTarget.className += newTarget.className ? " " : "";
// //     newTarget.className += theName;
// //     currentTarget = newTarget;
// //   }
// // }
// 
// function highlightElement(id) {
//   var optimalOffset = 50;
//   var obj = document.getElementById(id);
// 
//   winLeft = window.pageXOffset;
//   winTop = window.pageYOffset;
// 
//   objLeft = obj.offsetLeft;
//   objTop = obj.offsetTop;
//   while(obj.offsetParent != null){
//     objParent = obj.offsetParent;
//     objLeft += objParent.offsetLeft;
//     objTop += objParent.offsetTop;
//     obj = objParent;
//   }
// 
//   xOff = objLeft - winLeft - optimalOffset;
//   yOff = objTop - winTop - optimalOffset;
//   alert(winLeft + " " + winTop + " " + objLeft + " " + objTop + " " + xOff + " " + yOff);
// 
//   window.scrollTo(xOff, yOff);
// }
// 
// 
// // This is a cross-browser function for event addition.
// // If your JS already has a copy, feel free to remove this one.
// function addEvent(obj, evType, fn)
// {
//   if (obj.addEventListener)
//   {
//     obj.addEventListener(evType, fn, false);
//     return true;
//   }
//   else if (obj.attachEvent)
//   {
//     var r = obj.attachEvent("on" + evType, fn);
//     return r;
//   }
//   else
//   {
//     alert("Event handler could not be attached");
//     return false;
//   }
// }
// 
// alert('htjs');
// 

// include("http://localhost/~jmeyer/term-highlighter.js");
// include("http://localhost/~jmeyer/highlight-target.js");

// insert stylesheet for a.highlighted_term 
doHighlight('java.lang..*(?:Exception|Error):', true);