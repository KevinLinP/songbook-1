# TODO: fix allow and methods permissions

Songs = new Meteor.Collection 'song'

Songs.allow {
  insert: (userId, song) ->
    userId
  update: (userId, song, fieldName, modifier) ->
    userId
  remove: (userId, song) ->
    userId
}

Meteor.publish 'songTitles', ->
  Songs.find {}, {fields: {body: 0}}
  
Meteor.publish 'song', (songId) ->
  Songs.find {_id: songId}, {fields: {body: 1}}

Meteor.methods {
  clearSongs: ->
    return unless Meteor.userId()
    Songs.remove {}
  firstSongId: ->
    Songs.findOne({}, {sort:['title']})._id
}

Accounts.validateNewUser (user) ->
  user.emails[0].address == 'kevin.lin.p@gmail.com'
