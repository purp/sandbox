// Cached from http://www.gerv.net/software/thl/highlight-target.js
///////////////////////////////////////////////////////////////////////////////
//
// Target Highlighting Library v1.0
//
// Copyright (c) 2005 Gervase Markham
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
// Maintainer: gerv@gerv.net; http://www.gerv.net/software/thl/
//
// CHANGELOG:
//
// v1.0: Fix bug reported in blog by Gary van der Merwe (2005-10-03)
// v0.1: initial version (2005-09-25)
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//
// This library applies a class to the <a> element which was the target, if
// there was one, of the last link the user clicked.
//
// Use the following markup to include the library:
// <script type="text/javascript" src="highlight-target.js"></script>
//
// This library allows for separation of content and presentation. You style
// the target by styling the class "isTarget".
//
// .isTarget { color: red; }
//
// This class is applied to the element with the same ID as the anchor. Because
// names are checked before IDs, you can style a different element to the <a>
// if you wish:
// <h1 id="foo">This is a <a name="foo">heading</a></h1>
//
///////////////////////////////////////////////////////////////////////////////

var currentTarget = null;

addEvent(window, "load", prepareHighlightTarget);

function prepareHighlightTarget()
{
  if (document.getElementsByTagName)
  {
    // Set up a click listener on all links. It would be easier if we could
    // attach a change listener to location.href, but it seems we can't.
    var links = document.getElementsByTagName("a");
    
    for (var i = 0; i < links.length; i++)
    {
      if (links[i].getAttribute("href") != null)
      {
        addEvent(links[i], "click", highlightTarget)
      }
    }
    
    // Highlight any initial target
    var id = document.location.href.replace(/.*#/, "");
    if (id)
    {
      highlightElement(id);
    }
  }
}

function highlightTarget(e)
{
	if (!e) var e = window.event;

	var elem;  
	if (e.target)
  {
    elem = e.target;
  }
	else if (e.srcElement) 
  { 
    elem = e.srcElement;
  }
  
  // Move up the tree until we get to the A
  while (elem.nodeName != 'A')
  {
    elem = elem.parentNode;
  }
  
  var id = elem.getAttribute("href").replace(/.*#/, "");
  if (id)
  {
    highlightElement(id);
  }
}

// This could be rewritten to use generic class add/remove code if you have it
function highlightElement(id)
{
  var theName = "isTarget";
  
  // Remove class
  if (currentTarget)
  {
    var removeMe = currentTarget.className.match(" " + theName) ? " " : "";
    removeMe += theName;
    currentTarget.className = currentTarget.className.replace(removeMe, "");
  }
    
  var newTarget = document.getElementById(id);
  if (newTarget)
  {
    // Add class
    newTarget.className += newTarget.className ? " " : "";
    newTarget.className += theName;
    currentTarget = newTarget;
  }
}

// This is a cross-browser function for event addition.
// If your JS already has a copy, feel free to remove this one.
function addEvent(obj, evType, fn)
{
  if (obj.addEventListener)
  {
    obj.addEventListener(evType, fn, false);
    return true;
  }
  else if (obj.attachEvent)
  {
    var r = obj.attachEvent("on" + evType, fn);
    return r;
  }
  else
  {
    alert("Event handler could not be attached");
    return false;
  }
}

alert('htjs');