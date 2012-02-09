class TableHtml
  constructor: (@id, columnNames, className) ->
    @table = '<table id="' + @id + '" class="' + className + '"><thead><tr>'
    @columnsCount = columnNames.length
    @initialized = false
    for name in columnNames
      @table += '<td>' + name + '</td>'
    @table += '</tr></thead><tbody id="' + @id + 'body' + '"></tbody>'
    
  initialize: (containerId) =>
    $('#'+containerId).append(@table)
    @initialized = true
    
  addRow: (values) =>
    if @initialized
      tr = '<tr>'
      for value in values
        tr += '<td>' + value + '</td>'
      tr += '</tr>'
      $('#'+@id+'body').append(tr)
    

class SearchResultsView
  constructor: (@results) ->
    @table
    
  setView: (containerId) =>
    $('#'+containerId).html('')
    $('#'+containerId).append(SearchResultsView.getTitle('Wyniki wyszukiwania'))
    $('#'+containerId).append(SearchResultsView.getDiv('results'))
    @table = new TableHtml('resultsTable', 
      ['miejsce startowe', 'miejsce docelowe', 'ilość wolnych miejsc', 'data wyjazdu'], 'drives_index')
    @table.initialize('results')
    @table.addRow(['wroc', 'now', '23', '22-12-12'])
    
    
  @getTitle: (title) ->
    '<h1>' + title + '</h1>'
    
  @getDiv: (id) ->
    '<div id="' + id + '" ></div>'
    
    


window.SearchResultsView = SearchResultsView