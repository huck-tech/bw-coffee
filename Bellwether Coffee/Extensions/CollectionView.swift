
import UIKit

class CollectionView<T: CollectionViewCell>: View, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var actionDelegate: ActionDelegate?
    
    var collectionItems = [Any]() {
        didSet { updateCollectionItems() }
    }
    
    var cellSize = CGSize(width: 100, height: 100) {
        didSet { updateCellSize() }
    }
    
    var layout: UICollectionViewLayout? {
        didSet { updateLayout() }
    }
    
    var padding: CGSize? {
        didSet { updatePadding() }
    }
    
    var contentInset: UIEdgeInsets? {
        didSet { updateContentInset() }
    }
    
    var scrollInset: UIEdgeInsets? {
        didSet { updateScrollInset() }
    }
    
    var headerView: UIView? {
        didSet { updateHeaderView() }
    }
    
    var footerView: UIView? {
        didSet { updateFooterView() }
    }
    
    var scrollAction: ((CGPoint) -> Void)?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(T.self, forCellWithReuseIdentifier: defaultCellId)
        collectionView.register(CollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: defaultHeaderId)
        collectionView.register(CollectionViewFooter.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: defaultFooterId)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var selectedItems = [Int: Bool]()
    var supportsMultipleSelections: Bool = false
    
    var handleSelection: ((Int) -> Void)?
    var actionHandlers = [CollectionViewCellAction: ((Int) -> Void)?]()
    
    override func setupViews() {
        addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func handleSelection(_ handler: @escaping (Int) -> Void) {
        handleSelection = handler
    }
    
    func handleAction(_ action: CollectionViewCellAction, withHandler handler: @escaping (Int) -> Void) {
        actionHandlers[action] = handler
    }
    
    func updateCollectionItems() {
        collectionView.reloadData()
    }
    
    func updateCell(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func removeCell(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        })
    }
    
    func updateCellSize() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func updateLayout() {
        guard let collectionViewLayout = layout else { return }
        collectionView.collectionViewLayout = collectionViewLayout
    }
    
    func updatePadding() {
        guard let collectionPadding = padding else { return }
        
        let horizontalPadding = collectionPadding.width
        let verticalPadding = collectionPadding.height
        
        collectionView.contentInset = UIEdgeInsets(top: verticalPadding,
                                                   left: horizontalPadding,
                                                   bottom: verticalPadding,
                                                   right: horizontalPadding)
    }
    
    func updateContentInset() {
        guard let inset = contentInset else { return }
        collectionView.contentInset = inset
    }
    
    func updateScrollInset() {
        guard let inset = scrollInset else { return }
        collectionView.scrollIndicatorInsets = inset
    }
    
    func updateHeaderView() {
        collectionView.reloadData()
    }
    
    func updateFooterView() {
        collectionView.reloadData()
    }
    
    // MARK: UICollectionView Data Source
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellId, for: indexPath) as! T
        cell.cellIndex = indexPath.row
        cell.cellSelected = selectedItems[indexPath.row] ?? false
        cell.cellData = collectionItems[indexPath.row]
        
        if let target = cell as? Target {target.action(delegate: self.actionDelegate)}
        cell.cellAction = { [unowned self] index, action in
            self.actionHandlers[action]??(index)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: defaultHeaderId, for: indexPath) as! CollectionViewHeader
            header.headerView = headerView
            return header
        }
        
        if kind == UICollectionElementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: defaultFooterId, for: indexPath) as! CollectionViewFooter
            footer.footerView = footerView
            return footer
        }
        
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: defaultHeaderId, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItems.count
    }
    
    // MARK: UICollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleSelection(index: indexPath.row)
        clearSingleSelections(except: indexPath.row)
        
        handleSelection?(indexPath.row)
    }
    
    func toggleSelection(index: Int) {
        let selected = selectedItems[index] ?? false
        
        selectedItems[index] = supportsMultipleSelections ? !selected : true
        updateCell(index: index)
    }
    
    func clearSingleSelections(except: Int) {
        guard !supportsMultipleSelections else { return }
        
        selectedItems.forEach { key, value in
            guard key != except else { return }
            selectedItems[key] = false
            
            guard key < collectionItems.count else { return }
            updateCell(index: key)
        }
    }
    
    // MARK: UICollectionView Flow Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = cellSize.width == 0 ? bounds.width : cellSize.width
        let cellHeight = cellSize.height == 0 ? bounds.width : cellSize.height
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: UIScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollAction?(scrollView.contentOffset)
    }
    
}
