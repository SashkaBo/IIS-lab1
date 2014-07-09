require 'rubygems'
require 'json'
require 'pry'
require_relative 'additional.rb'

@rules_array = []
@conditions_list = {}

@context_stack = {}
@main_aim

@aims_stack = []

@questions = []

parse_json
create_conditions_list
ask_context_stack
main_method
