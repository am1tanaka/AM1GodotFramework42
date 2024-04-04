extends GutTest

func before_each():
	gut.p("ran setup", 2)

func after_each():
	gut.p("ran teardown", 2)

func before_all():
	gut.p("ran run setup", 2)

func after_all():
	gut.p("ran run teardown", 2)

func test_enqueue_and_dequeue():
	var queue = AM1Queue.new(3)
	assert_eq(0, queue.count, "数が0")

	gut.p("登録", 2)	
	var res = queue.enqueue(0)
	assert_true(res, "1つめ登録")
	assert_eq(queue.peek(0), 0, "1つめが0")
	assert_eq(queue.count, 1, "データ1つ")

	res = queue.enqueue(1)
	assert_true(res, "2つめ登録")
	assert_eq(queue.peek(1), 1, "2つめが1")
	assert_eq(queue.count, 2, "データ2つ")

	res = queue.enqueue(2)
	assert_true(res, "3つめ登録")
	assert_eq(queue.peek(2), 2, "3つめが2")
	assert_eq(queue.count, 3, "データ3つ")

	res = queue.enqueue(3)
	assert_false(res, "4つめは登録失敗")
	assert_eq(queue.peek(2), 2, "3つめは2のまま")
	assert_eq(queue.count, 3, "データ3つのまま")

	res = queue.enqueue(3, true)
	assert_true(res, "4つめを強制登録")
	assert_eq(queue.peek(2), 3, "3つめが3に")
	assert_eq(queue.count, 3, "データ3つのまま2")

	assert_eq(queue.peek(3), 1, "4つめは0に戻るので1")

	gut.p("取り出し", 2)
	var deq = queue.dequeue()
	assert_eq(deq, 1, "1つめは1")
	assert_eq(queue.count, 2, "データ2つ")

	deq = queue.dequeue()
	assert_eq(deq, 2, "2つめは2")
	assert_eq(queue.count, 1, "データ1つ")
	
	deq = queue.dequeue()
	assert_eq(deq, 3, "3つめは3")
	assert_eq(queue.count, 0, "データ0")

	deq = queue.dequeue()
	assert_false(deq, "4つめは失敗")
	assert_eq(queue.count, 0, "残りデータ数0")

	assert_false(queue.peek(0), "未登録なのでpeekはエラー")
