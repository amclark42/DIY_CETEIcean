// CETEIcean behaviors

var ceteiceanBehaviors = {
  'handlers': {
    'note': 
      [
        ['[target]', function(elt) {
            var noteId = elt.id,
                contentIdref = elt.getAttribute("target"),
                contentId = contentIdref.replace(/^#/,''),
                contentEl = document.getElementById(contentId),
                linkToContent = document.createElement('a'),
                linkToNote = document.createElement('a'),
                newNote = document.createElement('div'),
                newWrapper = document.createElement('div'),
                allNotes = document.querySelectorAll('tei-note'),
                noteIndex;
            /* Get the index of the current note among others of its type. */
            for (var index = 0; index < allNotes.length; i++) {
              if ( allNotes[index].isEqualNode(elt) ) {
                /* JS has zero-based indexes; add one for humans. */
                noteIndex = index + 1;
                break;
              }
            }
            /* Create the link to the note, from the annotated text. */
            linkToNote.href = '#'+noteId;
            linkToNote.className = "link-to-note";
            linkToNote.innerHTML = "["+noteIndex+"]";
            contentEl.parentNode.insertBefore(linkToNote, contentEl.nextSibling);
            /* Create the link to the annotated text, from the note. */
            linkToContent.href = contentIdref;
            linkToContent.className = "link-from-note";
            linkToContent.innerHTML = "["+noteIndex+"]";
            /* Recreate the note and put it in the wrapper. */
            newNote.innerHTML = elt.innerHTML;
            newWrapper.appendChild(linkToContent);
            newWrapper.appendChild(newNote);
            return newWrapper;
        }]
      ]
  }
};
