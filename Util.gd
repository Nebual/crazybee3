extends Node

# eg. limit = 0.95 means you'll get a random number between -0.95 and 0.95
func rand_signed_float(limit):
	return (randf() * limit * 2) - limit
