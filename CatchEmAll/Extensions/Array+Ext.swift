extension Array {
    subscript(back i: Int) -> Iterator.Element {
        return self[endIndex.advanced(by: -i)]
    }
}
