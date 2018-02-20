import UIKit



  public class ListNode {
      public var val: Int
      public var next: ListNode?
      public init(_ val: Int) {
          self.val = val
          self.next = nil
      }
  }
 

func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
    var carryOnValue = 0
    var firstList = l1
    var secondList = l2
    var listNode: ListNode?
    var currNode : ListNode?
    var firstListHasValue:  Bool = true
    var secondListHasValue:  Bool = true
    
    while firstListHasValue || secondListHasValue {
        let newValue = (firstList?.val ?? 0) + (secondList?.val ?? 0) + carryOnValue

        carryOnValue = newValue / 10
        if listNode == nil {
            listNode = ListNode.init(newValue % 10)
            currNode = listNode
        }
        else {
            currNode?.next = ListNode.init(newValue  % 10)
            currNode = currNode?.next
        }

        firstList = firstList?.next
        secondList = secondList?.next
        firstListHasValue = firstList == nil ? false : true
        secondListHasValue = secondList == nil ? false : true
        if !secondListHasValue && !firstListHasValue && carryOnValue != 0{
            currNode?.next = ListNode.init(carryOnValue)
        }
    }
    return listNode
}
func lengthOfLongestSubstring(_ s: String) -> Int {
    if s.isEmpty { return 0}
    if s.count == 1 { return 1}
    var arrayOfChars = Array(s)
    var leftPointer = 0
    var rightPointer = 0
    var maxInt = 0
    var  hash = [String.Element: Int]()
    for char in arrayOfChars {
        if hash[char] != nil {
            leftPointer = max(hash[char]! + 1, leftPointer)
            print("left is now: ", leftPointer)
        }
        print("curr char", char)
        print("leftPointer: ", leftPointer, " right pointer ", rightPointer )
        maxInt = max(maxInt, (rightPointer - leftPointer) + 1)
        hash[char] = rightPointer
        rightPointer += 1
    }
    return maxInt
}

var listNode1 = ListNode(5)
var listNode2 = ListNode(5)
//var listNode3 = ListNode(3)
listNode1.next = listNode2
//listNode2.next = listNode3


var listNode2_1 = ListNode(5)
var listNode2_2 = ListNode(5)
//var listNode2_3 = ListNode(4)
listNode2_1.next = listNode2_2
//listNode2_2.next = listNode2_3


//addTwoNumbers(listNode1, listNode2_1)
lengthOfLongestSubstring("abba")

/*
 Given a set, , of  distinct integers, print the size of a maximal subset, , of  where the sum of any  numbers in  is not evenly divisible by .
 
 Input Format
 
 The first line contains  space-separated integers,  and , respectively.
 The second line contains  space-separated integers (we'll refer to the  value as ) describing the unique values of the set.
 
 Constraints
 
 
 
 
 All of the given numbers are distinct.
 Output Format
 
 Print the size of the largest possible subset ().
 https://www.hackerrank.com/challenges/non-divisible-subset/problem
 */
//Answer: (Swift 3) uncommented due to unsupported function
//let infoArray: [Int] = readLine()!.characters.split(" ").map{Int(String($0))!}
//let subsetArray: [Int] = readLine()!.characters.split(" ").map{Int(String($0))!}
//var lengthOfSubset = 0
//var subSetRemainders = [Int](count: infoArray[1], repeatedValue: 0)
//
////print(subSetRemainders.count)
//var itemsWeAdded: [Int: Int] = [Int: Int]()
//for var i = 0 ; i < subsetArray.count ; i = i + 1 {
//    var willBeAdded = false;
//    subSetRemainders[subsetArray[i] % infoArray[1]] = subSetRemainders[subsetArray[i] % infoArray[1]] + 1
//}
//var count = min(subSetRemainders[0], 1)
////print(subSetRemainders)
//let startIndex = infoArray[1] - 1
//for var i in  startIndex.stride(to: 1, by: -1) {
//    let otherIndex = infoArray[1] - i
//    if(otherIndex == i){
//        continue
//    }
//    count = max(subSetRemainders[i], subSetRemainders[otherIndex]) + count
//    subSetRemainders[i] = 0
//    subSetRemainders[otherIndex] = 0
//}
//if infoArray[1] % 2 == 0 {
//    count = count + 1
//}



