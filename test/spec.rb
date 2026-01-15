
require_relative 'spec_helper'

RSpec.describe Telegem::Core::Bot do
  let(:token) { 'fake_token_123' }
  let(:bot) { described_class.new(token) }
  let(:mock_api) { instance_double('Telegem::API::Client') }

  before do
    allow(Telegem::API::Client).to receive(:new).and_return(mock_api)
  end

  describe '#initialize' do
    it 'sets token' do
      expect(bot.token).to eq(token)
    end

    it 'creates API client' do
      expect(bot.api).to eq(mock_api)
    end

    it 'has empty handlers hash' do
      expect(bot.handlers.keys).to eq([
        :message, :callback_query, :inline_query, 
        :chat_member, :poll, :pre_checkout_query, :shipping_query
      ])
    end

    it 'is not running initially' do
      expect(bot.running?).to be false
    end

    it 'creates memory session store by default' do
      expect(bot.session_store).to be_a(Telegem::Session::MemoryStore)
    end
  end

  describe '#command' do
    it 'registers command handler' do
      called = false
      
      bot.command('start') do |ctx|
        called = true
      end

      expect(bot.handlers[:message].size).to eq(1)
    end
  end

  describe '#hears' do
    it 'registers text pattern handler' do
      bot.hears(/hello/i) do |ctx|
        # handler
      end

      expect(bot.handlers[:message].size).to eq(1)
    end
  end

  describe '#scene' do
    it 'registers a scene' do
      bot.scene(:welcome) do |scene|
        scene.on_enter { |ctx| }
      end
      
      expect(bot.scenes[:welcome]).to be_a(Telegem::Core::Scene)
    end
  end

  describe '#process' do
    it 'processes update data' do
      update_data = { 'update_id' => 1 }
      update = Telegem::Types::Update.new(update_data)
      expect(Telegem::Types::Update).to receive(:new).with(update_data).and_return(update)
      expect(bot).to receive(:process_update).with(update)
      
      bot.process(update_data)
    end
  end

  describe '#shutdown' do
    it 'stops running' do
      bot.instance_variable_set(:@running, true)
      bot.shutdown
      expect(bot.running?).to be false
    end
  end

  describe 'private methods' do
    describe '#detect_update_type' do
      it 'detects message update' do
        update = Telegem::Types::Update.new('message' => { 'text' => 'hi' })
        result = bot.send(:detect_update_type, update)
        expect(result).to eq(:message)
      end

      it 'detects callback_query update' do
        update = Telegem::Types::Update.new('callback_query' => { 'id' => '123' })
        result = bot.send(:detect_update_type, update)
        expect(result).to eq(:callback_query)
      end

      it 'returns unknown for empty update' do
        update = Telegem::Types::Update.new({})
        result = bot.send(:detect_update_type, update)
        expect(result).to eq(:unknown)
      end
    end
  end

  describe 'webhook methods' do
    it 'sets webhook' do
      expect(mock_api).to receive(:call!).with('setWebhook', { url: 'https://example.com' }, any_args)
      bot.set_webhook('https://example.com')
    end

    it 'deletes webhook' do
      expect(mock_api).to receive(:call!).with('deleteWebhook', {}, any_args)
      bot.delete_webhook
    end
  end
end