require_relative 'question.rb'

def parse_json
  json = File.open('database.json'){ |file| file.read }
  @rules_array = JSON.parse(json)["questions"].map{ |q| Question.new(q) }
end

def create_conditions_list
  @rules_array.each do |rule| 
    rule.conditions.each do |key, value|
      @conditions_list[key] = [] unless @conditions_list.key?(key)
      @conditions_list[key] << value unless @conditions_list[key].include?(value)
    end
  end
end

def ask_context_stack  # надо бы переделать, пусть будет общение с пользователем через консоль   
  @context_stack["привод"] = "мускульная сила водителя"
  @main_aim = "тип транспортного средства"
end

def main_method
  @aims_stack << [@main_aim, -1]
  
  loop do
    last_aim = @aims_stack.last[0]
    rule_number = find_rule_number(@aims_stack.last[0])
    if rule_number
      break if analyze_rule(rule_number, last_aim)
    elsif @aims_stack.last[0] == @main_aim
      puts "Невозможно определить"
      break
    else
      puts "Введите значение параметра \"#{@aims_stack.last[0]}\""
      value = gets.chomp
      @context_stack[@aims_stack.last[0]] = value
      a = @aims_stack.pop  
      break if analyze_rule(a[1], @aims_stack.last[0])
    end #if 
  end #loop

  p @context_stack[@main_aim]
end

def find_rule_number(aim)
  a = @rules_array.select { |r| r.result.key?(aim) && r.mark != :forbid }
  a.first.id unless a.empty?
end

def analyze_rule(rule_number, aim)
  return_value = false

  case can_find_aim?(rule_number, aim)

  when 1
    r = @rules_array.index{ |r| r.id == rule_number }
    @context_stack[aim] = @rules_array[r].result[aim]
    @rules_array[r].mark = :accept

    @aims_stack.pop
    return_value = true if @aims_stack.empty?

  when -1
    r = @rules_array.index{ |r| r.id == rule_number }
    @rules_array[r].mark = :forbid

  when 0
    r = find_rule_by_id(rule_number)
    r.conditions.each do |key, value|
      unless @context_stack.key?(key) 
        @aims_stack << [key, rule_number]
        break
      end
    end      
  end #case

  return_value
end

def can_find_aim?(rule_number, aim)
  return_value = 1
  r = find_rule_by_id(rule_number)

  r.conditions.each do |key, value|
    if !@context_stack.key?(key)
      return_value = 0
    elsif @context_stack[key] != value 
      return_value = -1
      r.mark = :forbid
    end
  end
  return_value
end

def find_rule_by_id(rule_number)
  @rules_array.select{|r| r.id == rule_number}.first
end