class ContentTools.EmbedDialog extends ContentTools.DialogUI

  # A dialog to support inserting an embed (iframe)

  constructor: ()->
    super('Вставить плеер')

  clearPreview: () ->
    # Clear the current embed preview
    if @_domPreview
      @_domPreview.parentNode.removeChild(@_domPreview)
      @_domPreview = undefined

  mount: () ->
    # Mount the widget

    super()

    # Update dialog class
    ContentEdit.addCSSClass(@_domElement, 'ct-music-dialog')

    # Update view class
    ContentEdit.addCSSClass(@_domView, 'ct-music-dialog__preview')

    # Add controls
    domControlGroup = @constructor.createDiv(['ct-control-group'])
    @_domControls.appendChild(domControlGroup)

    # Input
    @_domInput = document.createElement('input')
    @_domInput.setAttribute('class', 'ct-video-dialog__input')
    @_domInput.setAttribute('name', 'url')
    @_domInput.setAttribute(
      'placeholder',
      ContentEdit._('Код плеера') + '...'
    )
    @_domInput.setAttribute('type', 'text')
    domControlGroup.appendChild(@_domInput)

    # Insert button
    @_domButton = @constructor.createDiv([
      'ct-control',
      'ct-control--text',
      'ct-control--insert'
      'ct-control--muted'
    ])
    @_domButton.textContent = ContentEdit._('Вставить')
    domControlGroup.appendChild(@_domButton)

    # Add interaction handlers
    @_addDOMEventListeners()

  preview: (iframe) ->
    # Preview the specified iframe

    # Remove any existing preview
    @clearPreview()

    @_domPreview = document.createRange().createContextualFragment(iframe).firstChild
    @_domView.appendChild(@_domPreview)

  save: () ->
    # Save the player. This method triggers the save method against the
    # dialog allowing the calling code to listen for the `save` event and
    # manage the outcome.

    # Attempt to parse a video embed URL
    @dispatchEvent(@createEvent('save', {'tag': @_domPreview}))

  show: () ->
    # Show the widget
    super()

    # Once visible automatically give focus to the link input
    @_domInput.focus()

  unmount: () ->
    # Unmount the component from the DOM

    # Unselect any content
    if @isMounted()
      @_domInput.blur()

    super()

    @_domButton = null
    @_domInput = null
    @_domPreview = null

  # Private methods

  _addDOMEventListeners: () ->
    # Add event listeners for the widget
    super()

    # Provide a preview of the video whenever a valid URL is inserted into
    # the input.
    @_domInput.addEventListener 'input', (ev) =>

      # If the input field is empty we disable the insert button
      if ev.target.value
        ContentEdit.removeCSSClass(@_domButton, 'ct-control--muted')
      else
        ContentEdit.addCSSClass(@_domButton, 'ct-control--muted')

      # We give the user half a second to make additional changes before
      # updating the preview video otherwise changes to the text input can
      # appear to stutter as the browser updates the preview on every
      # change.

      if @_updatePreviewTimeout
        clearTimeout(@_updatePreviewTimeout)

      updatePreview = () =>
        code = @_domInput.value.trim()
        if code
          @preview(code)
        else
          @clearPreview()

      @_updatePreviewTimeout = setTimeout(updatePreview, 500)

    # Add support for saving the player whenever the `return` key is pressed
    # or the button is selected.

    # Input
    @_domInput.addEventListener 'keypress', (ev) =>
      if ev.keyCode is 13
        @save()

    # Button
    @_domButton.addEventListener 'click', (ev) =>
      ev.preventDefault()

      # Check the button isn't muted, if it is then the video URL fields
      # isn't populated.
      cssClass = @_domButton.getAttribute('class')
      if cssClass.indexOf('ct-control--muted') == -1
        @save()