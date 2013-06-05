
# TODO: ON-On logo at bottom and info
# TODO: Page footer / site info
# TODO: Small touch device layout
# TODO: Un-auto-subscribe in the name of battery usage.
# TODO: Add length and type categories
# TODO: 'Wizard' to search song based on situation

Songs = new Meteor.Collection 'song'

Session.set 'isLoading', false
Session.set 'isNewSong', false

Meteor.subscribe 'songTitles', ->
  Meteor.call 'firstSongId', (error, id) ->
    Session.set 'songId', id

  mobile = ->
    a = (navigator.userAgent||navigator.vendor||window.opera)
    /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a) ||
    /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))

  $('body').addClass('is-mobile') if mobile()

  songCount = Songs.find({}).count()
  $('#song-search').attr('placeholder', "search #{songCount} hash songs")

  $(document).ready ->
    songs = Songs.find({}, {fields: {title: 1}}).fetch()
    titles = _.map songs, (song) ->
      {value: song.title, id: song._id}
    $('#song-search').autocomplete {
      source: titles
      delay: 50
      select: (event, ui) ->
        Session.set('songId', ui.item.id)
        Meteor.setTimeout( ->
          $(event.target).val('')
        , 100)
    }

Deps.autorun ->
  Meteor.subscribe 'song', Session.get('songId')

Template.songList.songs = ->
  Songs.find {}, {fields: {title: 1}, sort: ['title']}

Template.songList.rendered = ->
  $('#song-list').on 'click', 'a', ->
    id = $(this).attr 'data-id'
    Session.set 'songId', id
    $(document).scrollTop(0) if $('body').hasClass('is-mobile')

Template.songList.events {
  'click .js-new-song': (event) ->
    Session.set 'isNewSong', !Session.get('isNewSong')
}

Template.song.song = ->
  Songs.findOne Session.get('songId')

Template.song.isLoading = ->
  Session.get 'isLoading'

Template.song.isNewSong = ->
  Session.get 'isNewSong'

Template.song.events {
  'click .js-add-song': (event) ->
    title = $('.js-input-title').val()
    body = $('.js-input-body').val()
    $('.js-input-title').val('')
    $('.js-input-body').val('')
    id = Songs.insert {title: title, body: body}
    Session.set 'isNewSong', false
    Session.set 'songId', id
  'click .js-save-song': (event) ->
    title = $('.js-input-title').val()
    body = $('.js-input-body').val()
    Songs.update Session.get('songId'), {$set: {title: title, body: body}}
  'click .js-delete-song': (event) ->
    Songs.remove Session.get('songId')
  'click .js-load-json': (event) ->
    form = $('.js-json-form')
    songs = JSON.parse form.val()

    alert "parsed #{Object.keys(songs).length} songs. now inserting ..."

    for own title, body of songs
      Songs.insert {title: title, body: body}
  'click .js-clear-songs': (event) ->
    Meteor.call 'clearSongs'
}
