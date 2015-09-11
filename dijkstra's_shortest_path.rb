A = [30, 8, 3, 2, 1, 7, 4, 20]

module QuickSort
	def self.sort(array)
		QuickSort.quick_sort(array, 0, array.length - 1)
	end

	def self.quick_sort(array, left, right)
		if left < right
			pivot = QuickSort.partition(array, left, right)
			quick_sort(array, left, pivot - 1)
			quick_sort(array, pivot + 1, right)	
		end
	  array
	end

	def self.partition(array, left, right)
		x = array[right]
		i = left - 1
		for j in left..right - 1
			if array[j] <= x
				i += 1
				array[i], array[j] = array[j], array[i]
			end
		end
		array[i+1], array[right] = array[right], array[i+1]
		i+1
	end
end

puts QuickSort.sort(A)