# TODO: fix allow and methods permissions

Songs = new Meteor.Collection 'song'

Songs.allow {
  insert: (userId, song) ->
    true
  update: (userId, song, fieldName, modifier) ->
    true
  remove: (userId, song) ->
    true
}

Meteor.publish 'songTitles', ->
  Songs.find {}, {fields: {body: 0}}
  
Meteor.publish 'song', (songId) ->
  Songs.find {_id: songId}, {fields: {body: 1}}

Meteor.methods {
  clearSongs: ->
    return unless true
    Songs.remove {}
  firstSongId: ->
    Songs.findOne({}, {sort:['title']})._id
}

Accounts.validateNewUser (user) ->
  user.emails[0].address == 'kevin.lin.p@gmail.com'
