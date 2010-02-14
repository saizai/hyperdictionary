init_path = "#{Rails.root}/../../init.rb"
silence_warnings { eval(IO.read(init_path), binding, init_path) }
