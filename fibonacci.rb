def fibonacci(n)
	if n < 2
		return n
	else
		fibonacci(n-1) + fibonacci(n-2) 
	end
end

def path(n)
	if n == 1
		return 4
	else 
		return path(n-1) + path(n-1)
	end
end

puts path(2)

