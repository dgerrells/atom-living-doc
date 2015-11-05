{CompositeDisposable} = require 'atom'
fs = require 'fs'
path = require 'path'
module.exports = LivingDoc =
  subscriptions: null
  oldPaneItem: null

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'living-doc:open': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'living-doc:open-markdown': => @toggle(true)

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  toggle: (toggle) ->
    editor = atom.workspace.getActivePaneItem()
    if(!editor.buffer)
      return
    file = editor.buffer.file
    filePath = file?.path
    projectPath = atom.project.getPaths()[0]
    filePath = filePath.split(projectPath)[1]
    # '/documents'
    documentPath = path.join(projectPath, atom.config.get('living-doc.documentPath'))
    newFile = documentPath + filePath.replace('.', '-') + '.md'
    try
      if /\/$/.test(filePath)
        mkdirp newFile
      else
        if(fs.existsSync(newFile) && toggle)
          newFile = "markdown-preview://"+newFile
        if(@oldPaneItem?.id == atom.workspace.getActivePaneItem()?.id)
          atom.workspace.destroyActivePaneItem()
          return
        atom.workspace.open(newFile, split: 'right').then (editor) =>
          # if(@oldPaneItem?.id == atom.workspace.getActivePaneItem()?.id)
          #   atom.workspace.destroyActivePaneItem()
          @oldPaneItem = editor
    catch error
      console.log error.message

  config:
    documentPath:
      type: 'string'
      default: 'documents'
