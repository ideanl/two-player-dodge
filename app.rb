#!/usr/bin/env ruby
# encoding: UTF-8
require 'rubygems'
require 'sinatra'

get '/' do
  haml :index
end
