# dashing.js is located in the dashing framework
# It includes jquery & batman for you.
#= require dashing.js

#= require_directory .
#= require_tree ../../widgets

console.log("Yeah! The dashboard has started!")

Dashing.on 'ready', ->
  Dashing.debugMode = true
  Dashing.widget_margins ||= [5, 5]
  Dashing.widget_base_dimensions ||= [300, 360]
  Dashing.numColumns ||= 4
  
  contentWidth = (Dashing.widget_base_dimensions[0] + Dashing.widget_margins[0] * 2) * Dashing.numColumns
  # hide the mouse
  timeout = null
  $(document).on "mousemove", ->
    if timeout isnt null
      $("body").css cursor: ""
      $(".gs_w").css cursor: ""
      clearTimeout timeout
    timeout = setTimeout(->
      timeout = null
      $("body").css cursor: "none"
      $(".gs_w").css cursor: "none"
    , 5000)


  Batman.setImmediate ->
    $('.gridster').width(contentWidth)
    $('.gridster > ul').gridster
    #$('.gridster ul:first').gridster
      widget_margins: Dashing.widget_margins
      widget_base_dimensions: Dashing.widget_base_dimensions
      avoid_overlapped_widgets: !Dashing.customGridsterLayout
      draggable:
        stop: Dashing.showGridsterInstructions
        start: -> Dashing.currentWidgetPositions = Dashing.getWidgetPositions()
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent) )
      $(".gridster ul:first").gridster().data('gridster').draggable().disable();
