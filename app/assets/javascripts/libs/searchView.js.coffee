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
    $('#'+containerId).append(SearchResultsView.getDiv('results',''))
    if @results and @results.length > 0
      @table = new TableHtml('resultsTable', 
        ['miejsce startowe', 'miejsce docelowe', 'ilość wolnych miejsc', 'data wyjazdu', 'link'], 'drives_index')
      @table.initialize('results')
      @.showResultsInTable()
    else
      $('#'+containerId).append(SearchResultsView.getDiv('noResults', 'Nie znaleziono żadnych wyników.'))
    
  showResultsInTable: () =>
    for result in @results
      @table.addRow([result.start_city, result.destination_city, result.free_seats, result.date, 
        SearchResultsView.getLink(result.id)])
      
  @getLink: (resultId) ->
    baseUrl = (/http:\/\/[a-z0-9]+([\-\.:]{1}[a-z0-9]+)*/.exec document.location.href)[0]
    '<a href="' + baseUrl + '/drives/' + resultId + '">pokaż</a>'
    
  @getTitle: (title) ->
    '<h1>' + title + '</h1>'
    
  @getDiv: (id, content) ->
    '<div id="' + id + '" >' + content + '</div>'
    
    


window.SearchResultsView = SearchResultsView