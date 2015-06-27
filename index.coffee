Telegram = require 'telegram-bot'
Flickr = require "node-flickr"
keys = {"api_key": process.env.FLICKR_KEY}
flickr = new Flickr(keys)

tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)

tg.on 'message', (msg) ->
  return unless msg.text
  console.log msg
  text = msg.text.replace('@flickr_bot','').replace('!','')
  max = text.search(/count/i)
  count_string = text.substring(max, text.length)
  num = count_string.replace(/ /g,'').split('=')
  if max is -1
    search_term = text.trim()
  else
    search_term =  text.substring(0,max-1)
  if num.length isnt 0 and num[1] and num[1] < 15
    image_count = num[1]
  else
    image_count = 3
  flickr.get 'photos.search', { 'text': search_term, 'privacy_filter': 1, 'safe_search': 1, 'license': [1,2,3,4,5,6], 'per_page': image_count}, (err, result) ->
    if err
      console.error(err)
    photos = result.photos.photo
    reply_url =""
    if photos.length is 0
      reply_url ="Are you high?:p try something else."
      tg.sendMessage
        text: reply_url
        reply_to_message_id: msg.message_id
        chat_id: msg.chat.id
    else
      for photo in photos
        reply_url = 'https://farm'+photo.farm+'.staticflickr.com/'+photo.server+'/'+photo.id+'_'+photo.secret+'.jpg'
        tg.sendMessage
          text: reply_url
          reply_to_message_id: msg.message_id
          chat_id: msg.chat.id


tg.start()
