Template.grid.helpers
   checkDeelnemer: (id) ->
      if Deelnemers.findOne {opdrachtId:id}
         return true
      else
         return false
   deelnemer: (id) ->
      Deelnemers.find {opdrachtId:id}
   deelnemers: -> 16 - Deelnemers.find().count()

Template.grid.onRendered ->
   $('.popup').magnificPopup {type:'image'}

Template.timer.onRendered ->
   id = this.data._id
   time = this.data.time
   $("#"+this.data._id).countdown time
      .on 'update.countdown', (event) ->
         $(this).html(event.strftime('%D dagen %H:%M:%S'))
      .on 'finish.countdown', (event) ->
         Meteor.call 'releaseOpdracht', id

Template.signUp.onRendered ->
   time = this.data.countdown
   $("#countdownLock").countdown time
      .on 'update.countdown', (event) ->
         $(this).html(event.strftime('%M minuten en %S seconden'))
      .on 'finish.countdown', (event) ->
         Router.go '/'
         alert 'Code verlopen'

Template.insertCode.events
   'click button#submit': (e,t) ->
      code = $('#signUpCode').val()
      Meteor.call 'signUpCode', code, (e,r) ->
         if r is 'taken'
            alert 'Code al in gebruik. Probeer het later nog eens? Een code is slechts 15 minuten gereserveerd indien een registratie niet werd afgerond.'
         else if r is 'notValid'
            alert 'Geen geldige code'
         else
            Session.set 'opdracht', r
            Router.go '/signUp/' + r._id

Template.signUp.events
   'click #signUp': (e,t) ->
      e.preventDefault()
      if this.opdracht.duo
         users = [{},{}]
      else
         users = [{}]
      toGet = ['name','age','email','tel','skill1','skill2','skill3','info']
      _.each toGet, (val)->
         $(".#{val}").each (i) ->
            users[i][val] = $(this).val()
      agree = $('#agree').prop('checked')
      unless users[0].name and users[0].age and users[0].email and users[0].tel and users[0].skill1 and users[0].skill2 and users[0].skill3 and agree
         alert 'Niet alle velden zijn ingevuld'
         return
      else if this.opdracht.duo
         unless users[1].name and users[1].age and users[1].email and users[1].tel and users[1].skill1 and users[1].skill2 and users[1].skill3 and agree
            alert 'Niet alle velden zijn ingevuld'
            return
      Meteor.call 'signUp', Session.get('opdracht'), users, (e,r) ->
         if e
            alert 'Er is iets misgegaan. Mischien is je code ongeldig of al verlopen?'
            Router.go '/'
         else
            alert 'Je bent nu officiëel ingeschreven voor The Survival Games. Meer info volgt.'
            Router.go '/'