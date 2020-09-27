// CETEIcean behaviors

/* Definitions which tell CETEIcean how elements should be translated into HTML. See 
   the CETEIcean tutorial for more on how to implement your own behaviors: 
   https://github.com/TEIC/CETEIcean/tree/master/tutorial_en
 */
var ceteiceanBehaviors = {
  /* Custom behaviors for elements originally in the TEI namespace. */
  'tei': {
    
    /* Override default CETEIcean behavior so it doesn't hide the <tei:teiHeader>. */
    'teiHeader': null,
    
    /* Wrap the document's primary title in an <h1>. */
    'title': [
        ['tei-titleStmt > tei-title:first-of-type', ['<h1>','</h1>']]
      ],
    
    /* Block-level things. Use semantic HTML markup where possible for accessibility 
       purposes. */
    'floatingText': ['<article>','</article>'],
    'front': ['<section>','</section>'],
    'body': ['<main>','</main>'],
    'back': ['<section>','</section>'],
    'div': ['<div>','</div>'], // TODO: numbered <div>s?
    'p': ['<p>','</p>'],
    
    /*'head': [
        ['tei-table>tei-head', function(elt) {
            let caption = document.createElement('caption');
            caption.innerHTML = elt.innerHTML;
            return caption;
          }]
      ],*/
    
    /* For <tei:note>s which have @target, create a link from the note to its target, 
       and likewise from the target to the note. */
    'note': [
        ['[target]', function(elt) {
            var noteId = elt.id,
                contentIdref = elt.getAttribute("target"),
                contentId = contentIdref.replace(/^#/, ''),
                contentEl = document.getElementById(contentId),
                linkToContent = document.createElement('a'),
                linkToNote = document.createElement('a'),
                newNote = document.createElement('div'),
                newWrapper = document.createElement('div'),
                allNotes = document.querySelectorAll('tei-note'),
                noteIndex;
            /* Get the index of the current note among others of its type. */
            for (var index = 0; index < allNotes.length; index++) {
              if ( allNotes[index].isEqualNode(elt) ) {
                /* JS has zero-based indexes; add one for humans. */
                noteIndex = index + 1;
                /* Break out of the loop; there's no point in testing any remaining 
                 * notes. */
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
      ],
    
    /* Table behaviors.
      TODO: work on this; it's an accessibility nightmare
     */
    'table': ['<table>','</table>']/*,
    'row': ['<tr>','</tr>'],
    'cell': [
        ['tei-row[role="label"] > tei-cell', function(elt) {
            let cell = document.createElement('th');
            cell.innerHTML = elt.innerHTML;
            return cell;
          }],
        ['_', function(elt) {
            let cell = document.createElement('td');
            cell.innerHTML = elt.innerHTML;
            return cell;
          }]
      ]*/
  }
};
