class ChatRoomsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :create, :show]
  before_action :set_current_user_chat_rooms, only: [:index, :create]
  before_action :are_you_current_user?, only: [:index]
  before_action :your_message_form?, only: [:show] # 自分でないメッセージフォームには行かせない

  def index
    @chat_room_users = ChatRoomUser.includes(:user).where(chat_room: @current_user_chat_rooms).where.not(user_id: current_user.id) # 自身がが入るチャットルームにいる相手の中間テーブルを持ってくる
    @chat_messages = ChatMessage.all
  end

  def create
    @chat_room = ChatRoomUser.where(chat_room: @current_user_chat_rooms, user_id: params[:user_id]).map(&:chat_room).first
    if @chat_room.blank?
      @chat_room = ChatRoom.create # ルームの作成してから
      # 中間テーブルに登録
      ChatRoomUser.create(chat_room: @chat_room, user_id: current_user.id)
      ChatRoomUser.create(chat_room: @chat_room, user_id: params[:user_id])
    end
    redirect_to action: :show, id: @chat_room.id
  end

  def show
    @chat_room = ChatRoom.find(params[:id]) # ルーム取得
    @chat_room_user = @chat_room.chat_room_users.where.not(user_id: current_user.id).first.user # ルーム相手の情報
    @chat_messages = ChatMessage.where(chat_room: @chat_room) # message内容を取得
    are_you_check? # 既読したかどうか
    @chat_message = ChatMessage.new
    $current_user_id=params[:user_id]#最終扇
  end

  private

  def are_you_current_user?
    redirect_to root_path unless current_user.id == params[:user_id].to_i
  end

  def set_current_user_chat_rooms
    @current_user_chat_rooms = ChatRoomUser.where(user_id: current_user.id).map(&:chat_room) # 自身のチャットルーム全てを配列として集める
  end

  def your_message_form?
    redirect_to root_path unless ChatRoomUser.find_by(chat_room_id: params[:id], user_id: current_user)
  end

  # 既読チェッカー
  def are_you_check?
    @messages_to_me = ChatMessage.where(chat_room: @chat_room, user_id: @chat_room_user) # 相手から自分宛のメッセのみ取得
    @messages_to_me.each do |message|  # 開いた時点で自分宛のメッセをcheckをtrueにする
      message.check = true
      message.save
    end
  end
end
