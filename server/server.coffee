Meteor.publish "opdrachten", (id) ->
   transform = (doc) ->
      unless new Date(doc.ISOTime) < new Date()
         doc.opdracht = false
      unless doc.locked is 'forever'
         doc.code = undefined
      doc.comment = undefined
      return doc
   self = this
   observer = Opdrachten.find().observe 
      added: (doc) ->
         self.added "opdrachten", doc._id, transform(doc)
      changed: (newDoc, oldDoc) ->
         self.changed "opdrachten", oldDoc._id, transform(newDoc)
   self.onStop ->
      observer.stop()
   self.ready()

Meteor.publish 'deelnemers', ->
   Deelnemers.find {}#, {fields:{name:1,age:1,skills:1}}

unlockOpdracht = (code) ->
   Meteor.setTimeout ->
      unless Opdrachten.findOne({code:code}).locked is 'forever'
         Opdrachten.update {code:code}, {$set:{locked:false}}
   , 900000

Meteor.methods
   signUpCode: (ucode) ->
      Codes.insert {code:ucode}
      code = ucode.toLowerCase()
      opdracht = Opdrachten.findOne {code:code}
      if opdracht
         unless opdracht.locked
            Opdrachten.update {code:code}, {$set:{locked:new Date()}}
            unlockOpdracht code
            return _.pick opdracht, '_id','duo','code'
         else
            return 'taken'
      else
         return 'notValid'
   releaseOpdracht: (id) ->
      if new Date(Opdrachten.findOne({_id:id}).ISOTime) < new Date()
         Opdrachten.update {_id:id}, {$set:{released:true}}
   signUp: (opdr, users) ->
      opdracht = Opdrachten.findOne({_id:opdr._id})
      if opdracht
         Opdrachten.update {_id:opdracht._id}, {$set:{locked:'forever'}}
         _.each users, (user)->
            Deelnemers.insert _.extend user, {opdrachtId:opdracht._id}