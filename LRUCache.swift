//
//  LRUCache.swift
//
//  Created by Hovik Melikyan on 31/10/2019.
//

import Foundation


struct LRUCache<K: Hashable, E>: Sequence {

	private struct BubbleList {

		class Node {
			var key: K
			var value: E
			var down: Node?
			weak var up: Node?

			init(key: K, value: E) {
				self.key = key
				self.value = value
			}
		}


		private(set) var top: Node?
		private(set) var bottom: Node?
		private(set) var count: Int = 0

		var isEmpty: Bool { count == 0 }


		@discardableResult
		mutating func add(key: K, value: E) -> Node {
			return add(node: Node(key: key, value: value))
		}


		mutating func moveToTop(node: Node) {
			if top !== node {
				remove(node: node)
				add(node: node)
			}
		}


		@discardableResult
		mutating func removeBottom() -> Node {
			remove(node: bottom!)
		}


		mutating func removeAll() {
			top = nil
			bottom = nil
			count = 0
		}


		@discardableResult
		private mutating func add(node: Node) -> Node {
			if let top = top {
				node.down = top
				top.up = node
			}
			else {
				bottom = node
			}
			top = node
			count += 1
			return node
		}


		@discardableResult
		mutating func remove(node: Node) -> Node {
			let up = node.up
			let down = node.down
			if let up = up {
				up.down = down
			} else {
				top = down
			}
			if let down = down {
				down.up = up
			}
			else {
				bottom = up
			}
			node.up = nil
			node.down = nil
			count -= 1
			return node
		}
	}


	private(set) var capacity: Int

	var count: Int { list.count }
	var isEmpty: Bool { list.isEmpty }

	private var list = BubbleList()
	private var dict = Dictionary<K, BubbleList.Node>()


	init(capacity: Int) {
		precondition(capacity > 0)
		self.capacity = capacity
	}


	mutating func set(_ element: E, forKey key: K) {
		if let node = dict[key] {
			node.value = element
			list.moveToTop(node: node)
		}
		else {
			if list.count == capacity {
				let key = list.removeBottom().key
				dict.removeValue(forKey: key)
			}
			dict[key] = list.add(key: key, value: element)
		}
	}


	mutating func touch(key: K) -> E? {
		if let node = dict[key] {
			list.moveToTop(node: node)
			return node.value
		}
		return nil
	}


	mutating func remove(key: K) {
		if let node = dict[key] {
			list.remove(node: node)
			dict.removeValue(forKey: key)
		}
	}


	mutating func removeAll() {
		list.removeAll()
		dict.removeAll()
	}


	// MARK: - iterator/sequence

	struct Iterator: IteratorProtocol {
		typealias Element = E
		private var currentNode: BubbleList.Node?

		init(iteree: LRUCache) {
			currentNode = iteree.list.top
		}

		mutating func next() -> E? {
			defer { currentNode = currentNode?.down }
			return currentNode?.value
		}
	}


	__consuming func makeIterator() -> Iterator {
		return Iterator(iteree: self)
	}
}
