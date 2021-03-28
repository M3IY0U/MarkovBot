# frozen_string_literal: true

require 'ruby_markovify'
require 'discordrb'

bot = Discordrb::Commands::CommandBot.new token: File.read('token.txt'),
                                          prefix: 'd!',
                                          ignore_bots: true

bot.bucket :CoolDown, limit: 1, time_span: 5, delay: 0

@chains = {}

# remove model from markov chain
bot.command(:disable, min_args: 1, max_args: 1, help_available: false) do |event, which|
  break unless event.user.id == 137_234_090_309_976_064

  begin
    @chains.delete(which)
  rescue StandardError => e
    return e
  end
  event.message.create_reaction '✅'
  return "#{which} is kill"
end

# init/add model to markov chain
bot.command(:enable, min_args: 1, max_args: 1, help_available: false) do |event, which|
  break unless event.user.id == 137_234_090_309_976_064

  t1 = Time.now
  begin
    @chains[which] = RubyMarkovify::ArrayText.new(File.readlines("#{which}.txt", chomp: true), 2)
  rescue StandardError => e
    return e
  end
  event.message.create_reaction '✅'
  return "#{which} is alive (took #{Time.now - t1} seconds)"
end

# create a deep:tm: message by walking the markov chain
bot.command(:deep, aliases: [:Deep], bucket: :CoolDown) do |_event, user|
  return "#{user} not currently loaded" unless @chains.key? user

  generate_text @chains[user]
end

bot.command(:eval, help_available: false) do |event, *code|
  break unless event.user.id == 137_234_090_309_976_064

  begin
    eval code.join ' '
  rescue StandardError => e
    return e.inspect
  end
end

def generate_text(user)
  r = user.make_sentence
  r = user.make_sentence while r.nil?
  r
end

bot.run
