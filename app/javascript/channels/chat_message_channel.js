import consumer from "./consumer"

consumer.subscriptions.create("ChatMessageChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    const html = `
    <div class="my_message_box">
      <div class="my_message">
      ${data.content.content}
      </div>
    </div>
    `;
    const messages = document.getElementById('messages');
    const newMessage = document.getElementById('chat_message_content');
    messages.insertAdjacentHTML('beforeend', html);
    newMessage.value='';
  }
});