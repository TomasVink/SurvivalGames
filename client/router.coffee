Router.route '/',
   name: 'home'
   template: 'grid'
   waitOn: ->
      Meteor.subscribe "opdrachten"
      Meteor.subscribe "deelnemers"
   data: ->
      opdrachten: Opdrachten.find {},{sort:{order:1}}
      deelnemers: Deelnemers.find()

Router.route '/signUp/:id?',
   name: 'signUp'
   waitOn: -> Meteor.subscribe 'opdrachten'
   data: ->
      opdracht = Opdrachten.findOne {_id:this.params.id}
      data =
         countdown: new XDate(opdracht.locked).addMinutes(15).toString('yyyy/MM/dd HH:mm:ss')
         opdracht: opdracht
      return data
   onBeforeAction: ->
      if Opdrachten.findOne {_id:this.params.id}
         this.next()
      else
         Router.go '/'

Router.configure
   layoutTemplate: 'layout'
   loadingTemplate: 'loading'