The Context object (ctx) is the heart of every Telegem bot handler. It provides access to everything about the current update and methods to interact with Telegram.

---

📦 Basic Properties

Property Type Description
ctx.update Update Raw Telegram update object
ctx.bot Bot The bot instance
ctx.state Hash Temporary state for current request (cleared after)
ctx.session Hash Persistent user session (stored between requests)
ctx.match MatchData Regex match data from hears or pattern matching
ctx.scene String Current scene name (if in a scene)

---

👤 User & Chat Information

```ruby
ctx.from          # User who sent the message
ctx.from.id       # User ID
ctx.from.username # Username (may be nil)
ctx.from.first_name
ctx.from.last_name

ctx.chat          # Current chat
ctx.chat.id       # Chat ID
ctx.chat.type     # "private", "group", "supergroup", "channel"

ctx.user_id       # Shortcut for ctx.from&.id
```

---

📨 Message Access

```ruby
ctx.message                    # Current message
ctx.message.text               # Message text
ctx.message.caption            # Caption for media
ctx.message.message_id
ctx.message.date

ctx.message.reply_to_message   # Message being replied to
ctx.reply_to_message           # Same as above

ctx.message.photo              # Array of photo sizes
ctx.message.document           # Document object
ctx.message.audio
ctx.message.video
ctx.message.voice
ctx.message.sticker
ctx.message.location

ctx.message.entities           # Formatting entities
ctx.message.caption_entities   # Caption entities
```

---

🔍 Update Type Detection

```ruby
ctx.callback_query     # Callback query object (if present)
ctx.inline_query       # Inline query object
ctx.chosen_inline_result
ctx.poll               # Poll object
ctx.poll_answer
ctx.chat_member
ctx.my_chat_member
ctx.chat_join_request
```

---

📝 Message Content Shortcuts

```ruby
ctx.text               # ctx.message&.text
ctx.data               # ctx.callback_query&.data
ctx.query              # ctx.inline_query&.query
ctx.command?           # True if message is a command
ctx.command            # Command name (e.g., "start")
ctx.command_args       # Arguments after command
```

---

💬 Sending Messages

Basic Text

```ruby
ctx.reply("Hello world")                    # Simple reply
ctx.reply("Hello", parse_mode: "Markdown")  # With formatting
ctx.reply("Hello", disable_web_page_preview: true)
ctx.reply("Hello", reply_to_message_id: 123)
```

With Keyboard

```ruby
# Reply keyboard
keyboard = Telegem::Markup.keyboard do
  button "Option 1"
  button "Option 2"
  request_location "Share Location"
end
ctx.reply("Choose:", reply_markup: keyboard)

# Inline keyboard
inline = Telegem::Markup.inline do
  callback "Yes", "confirm"
  callback "No", "cancel"
  url "Visit", "https://example.com"
end
ctx.reply("Confirm?", reply_markup: inline)
```

Remove Keyboard

```ruby
ctx.remove_keyboard                    # Just removes keyboard
ctx.remove_keyboard("Done!")            # Sends message + removes keyboard
ctx.remove_keyboard(selective: true)    # Only for specific users
```

Force Reply

```ruby
ctx.reply("What's your name?", reply_markup: Telegem::Markup.force_reply)
```

---

🖼️ Sending Media

Photos

```ruby
ctx.photo("https://example.com/image.jpg")
ctx.photo("https://example.com/image.jpg", caption: "Beautiful gem")
ctx.photo(File.open("local.jpg"))
ctx.photo(File.open("local.jpg"), caption: "Local file")
```

Documents

```ruby
ctx.document("https://example.com/file.pdf")
ctx.document(File.open("report.pdf"), caption: "Monthly report")
ctx.document(file_id)  # Using Telegram file_id
```

Audio

```ruby
ctx.audio("song.mp3", title: "My Song", performer: "Artist", duration: 180)
```

Video

```ruby
ctx.video("video.mp4", caption: "Check this out", width: 1920, height: 1080)
```

Voice

```ruby
ctx.voice("voice.ogg")  # Must be OGG format
```

Sticker

```ruby
ctx.sticker("CAACAgIAAxkBAAIBZmd...")  # Sticker file_id
```

Location

```ruby
ctx.location(6.454, 3.394)  # Latitude, Longitude
```

Contact

```ruby
ctx.contact("+1234567890", "John", last_name: "Doe")
```

---

✏️ Editing Messages

```ruby
ctx.edit_message_text("Updated text")
ctx.edit_message_text("New text", message_id: 123)  # Specific message

ctx.edit_message_caption("New caption")
ctx.edit_message_media(new_photo)
ctx.edit_message_reply_markup(new_keyboard)

ctx.edit_message_live_location(6.455, 3.395)  # For live locations
ctx.stop_message_live_location
```

---

❌ Deleting Messages

```ruby
ctx.delete_message                 # Deletes current message
ctx.delete_message(123)            # Deletes specific message ID
```

---

🔄 Replying to Callbacks

```ruby
ctx.answer_callback_query("Done!")                    # Simple toast
ctx.answer_callback_query("Error!", show_alert: true) # Alert popup
ctx.answer_callback_query(url: "https://example.com") # Open URL
ctx.answer_callback_query(text: "Loading...", cache_time: 5)
```

---

🔎 Inline Queries

```ruby
ctx.answer_inline_query(results, cache_time: 300)
ctx.answer_inline_query(results, next_offset: "20")  # Pagination

# Results array of InlineQueryResult objects
results = [
  Telegem::Types::InlineQueryResultArticle.new(
    id: "1",
    title: "Result",
    input_message_content: { message_text: "Text" }
  )
]
```

---

📥 File Operations

```ruby
ctx.download_file(file_id, "local/path")  # Download file
ctx.file(file_id)                          # Get file info
ctx.file_path(file_id)                     # Get path on Telegram servers
```

---

🎬 Chat Actions (Typing Indicators)

```ruby
ctx.typing                          # "typing..."
ctx.uploading_photo                  # "sending photo..."
ctx.uploading_video                  # "sending video..."
ctx.uploading_audio                  # "sending audio..."
ctx.uploading_document                # "sending document..."
ctx.find_location                     # "finding location..."
ctx.record_video                      # "recording video..."
ctx.record_audio                      # "recording audio..."
ctx.choose_sticker                    # "choosing sticker..."
```

All accept optional **options:

```ruby
ctx.typing(business_connection_id: "123")  # For business connections
```

---

👥 Chat Management

```ruby
ctx.kick_chat_member(user_id)                 # Kick user
ctx.ban_chat_member(user_id, until_date: future_time)
ctx.unban_chat_member(user_id, only_if_banned: true)

ctx.restrict_chat_member(user_id, permissions: { can_send_messages: false })
ctx.promote_chat_member(user_id, can_invite_users: true)

ctx.get_chat_administrators
ctx.get_chat_member(user_id)
ctx.get_chat_members_count

ctx.leave_chat
```

---

📌 Pinning Messages

```ruby
ctx.pin_message(123)                        # Pin message
ctx.pin_message(123, disable_notification: true)
ctx.unpin_message                            # Unpin current
ctx.unpin_message(123)                       # Unpin specific
ctx.unpin_all_messages
```

---

🔁 Forwarding & Copying

```ruby
ctx.forward_message(from_chat_id, message_id)
ctx.copy_message(from_chat_id, message_id, caption: "New caption")
```

---

🌐 Web App & Polls

```ruby
ctx.web_app_data                # Data from Web App

ctx.send_poll("Question?", ["Option1", "Option2"], is_anonymous: true)
ctx.stop_poll(message_id)
```

---

🎭 Scenes (Multi-step Conversations)

```ruby
ctx.enter_scene(:survey)         # Enter scene
ctx.leave_scene                   # Leave current scene
ctx.leave_scene(reason: :cancel) # Leave with reason
ctx.in_scene?                     # Check if in a scene
ctx.current_scene                 # Get current scene name

ctx.ask("What's your name?")      # Prompt for response (scene helper)
ctx.next_step                      # Move to next scene step
ctx.next_step(:payment)            # Move to specific step
ctx.scene_data                     # Get scene data hash
```

---

🎨 Keyboard Building Helpers

```ruby
# Create and use in one line
ctx.reply_with_keyboard("Choose:", Telegem::Markup.keyboard { button "Yes" })

ctx.reply_with_inline_keyboard("Options:", Telegem::Markup.inline { callback "Yes", "data" })
```

---

📊 Poll Helpers

```ruby
ctx.poll?                         # True if update is a poll
ctx.poll_answer?                   # True if poll answer
ctx.poll_answer                     # Get poll answer object
```

---

⏱️ Timing & Metadata

```ruby
ctx.logger                         # Bot's logger
ctx.api                             # Direct API client
ctx.raw_update                      # Original update hash
ctx.update_id                       # Update ID
```

---

🔄 Session Management

```ruby
ctx.session[:user_preference] = "dark"  # Store in session
pref = ctx.session[:user_preference]     # Retrieve
ctx.session.delete(:temp_data)           # Delete
ctx.session.clear                         # Clear all
```

---

🎯 Complete Usage Example

```ruby
bot.command('start') do |ctx|
  ctx.session[:visits] ||= 0
  ctx.session[:visits] += 1
  
  keyboard = Telegem::Markup.keyboard do
    button "💎 Random Gem"
    request_location "📍 Share Location"
  end
  
  ctx.reply(
    "Welcome! You've visited #{ctx.session[:visits]} times", 
    reply_markup: keyboard
  )
end

bot.hears(/^gem$/i) do |ctx|
  ctx.typing
  sleep 1  # Simulate processing
  
  gem = GemDatabase.random
  ctx.photo(gem.image_url, caption: "#{gem.name}\n#{gem.fact}")
end

bot.callback_query('favorite') do |ctx|
  gem_id = ctx.data.split('_').last
  ctx.session[:favorites] ||= []
  ctx.session[:favorites] << gem_id
  
  ctx.answer_callback_query("Added to favorites! ❤️")
  ctx.edit_message_text("⭐ Favorited!")
end
```

---

⚠️ Error Handling

```ruby
bot.error do |error, ctx|
  ctx.logger.error("Error for user #{ctx.user_id}: #{error.message}")
  ctx.reply("Something went wrong. Please try again.") if ctx.chat
end
```

---