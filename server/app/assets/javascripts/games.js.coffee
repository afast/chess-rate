# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

timeouts = {}

updateProgress = ($div, id) ->
  $.get "/games/#{id}/progress", (data) ->
    $div.find('div.bar').width("#{data}%")
    if data.indexOf('100') >= 0
      clearInterval timeouts[id]
      $.get "/games/#{id}/statistics", (data) ->
        $div.closest('td').replaceWith data

$ ->
  if $('div.progress').length > 0
    $('div.progress').each () ->
      $div = $(this)
      id = $div.closest('tr').prop('id')
      timeouts[id] = setInterval ()->
        updateProgress $div, id
      , 2000
