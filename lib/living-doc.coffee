{CompositeDisposable} = require 'atom'
fs = require 'fs'
paths = require 'path'
module.exports = LivingDoc =
  subscriptions: null
  oldPaneItem: null

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'living-doc:open-file': => @openLivingFile()
    @subscriptions.add atom.commands.add 'atom-workspace', 'living-doc:open-file-preview': => @openLivingFile(true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'living-doc:open-folder': => @openLivingFolder()
    @subscriptions.add atom.commands.add 'atom-workspace', 'living-doc:open-folder-preview': => @openLivingFolder(true)

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  openLivingFile: (preview) ->
    livingFilePath = @getFileDocumentPath(@getCurrentOpenFilePath())
    if !(@canOpenFilePath(livingFilePath) && livingFilePath)
      return
    if @pathExists(livingFilePath)
      mkdirp livingFilePath
    else
      if(preview)
        livingFilePath = "markdown-preview://"+livingFilePath
      @openFileTab(livingFilePath)

  openLivingFolder: (preview) ->
    livingFolderPath = @getFolderDocumentPath(@getCurrentOpenFilePath())
    if !(@canOpenFilePath(livingFolderPath) && livingFolderPath)
      return
    if @pathExists(livingFolderPath)
      mkdirp livingFolderPath
    else
      if(preview)
        livingFilePath = "markdown-preview://"+livingFolderPath
      @openFileTab(livingFolderPath)

  canOpenFilePath: (filePath) ->
    currentOpenFile = atom.workspace.getActivePaneItem().filePath
    if(@oldPaneItem?.id == atom.workspace.getActivePaneItem()?.id)
      atom.workspace.destroyActivePaneItem()
      return false
    if currentOpenFile && currentOpenFile.indexOf(atom.config.get('living-doc.documentPath') == -1)
      atom.workspace.destroyActivePaneItem()
      return false
    return true

  openFileTab: (file) ->
    atom.workspace.open(file, split: 'right').then (editor) =>
      @oldPaneItem = editor

  getCurrentOpenFilePath: ->
    editor = atom.workspace.getActivePaneItem()
    if(!editor.buffer || !editor.buffer.file)
      return undefined
    return editor.buffer.file.path

  pathExists: (path) ->
    projectPath = @getProjectPath()
    relativePath = path.split(projectPath)[1]
    return /\/$/.test(relativePath)

  getDocumentPath: (filePath) ->
    relativeFilePath = @getRelativeSourcePath(filePath)
    if !relativeFilePath
      return undefined
    documentPath = atom.config.get('living-doc.documentPath')
    documentPath = paths.join(@getProjectPath(), documentPath)
    return documentPath + relativeFilePath

  getRelativeSourcePath: (filePath) ->
    projectPath = @getProjectPath()
    configSourcePath = atom.config.get('living-doc.sourcePath') || ''
    relativeFilePath = filePath.split(paths.join(projectPath, configSourcePath))[1]
    return relativeFilePath

  getProjectPath: ->
    return atom.project.getPaths()[0]

  getFileDocumentPath: (filePath) ->
    if !filePath || !@getDocumentPath(filePath)
      return undefined
    return @getDocumentPath(filePath) + '.md'

  getFolderDocumentPath: (filePath) ->
    if !filePath || !@getDocumentPath(filePath)
      return undefined
    folderName = @getFolderDocumentName(filePath)
    fileDocumentPath = @getDocumentPath(filePath)
    if !folderName || !fileDocumentPath
      return undefined
    folderPath = paths.join(filePath.split(folderName)[0], folderName)
    return paths.join(folderPath, folderName) + '.md'

  getFolderDocumentName: (filePath) ->
    folderPath = filePath.split('\\')
    folderName = folderPath[folderPath.length-2]
    if !folderName
      return undefined
    return folderName

  config:
    documentPath:
      type: 'string'
      default: 'documents'
    sourcePath:
      type: 'string'
      default: ''
