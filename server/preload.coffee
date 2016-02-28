loadOpdrachten = ->
   data = EJSON.parse(Assets.getText("opdrachtendata.json"))
   Opdrachten.remove {}
   console.log "preloading data"
   _.each data, (el) ->
      Opdrachten.insert el

Meteor.startup ->
   if Opdrachten.find().count() is 0
      loadOpdrachten()