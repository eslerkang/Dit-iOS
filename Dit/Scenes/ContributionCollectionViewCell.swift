//
//  ContributionCollectionViewCell.swift
//  Dit
//
//  Created by 강태준 on 2022/09/08.
//

import UIKit
import SnapKit


final class ContributionCollectionViewCell: UICollectionViewCell {
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    func setup(contribution: Contribution) {
        var backgroundColor: UIColor
        switch contribution.commit {
        case 0:
            backgroundColor = UIColor.secondaryLabel
        case 1:
            backgroundColor = CustomColor.green1
        case 2:
            backgroundColor = CustomColor.green2
        case 3:
            backgroundColor = CustomColor.green3
        case 4:
            backgroundColor = CustomColor.green4
        default:
            backgroundColor = CustomColor.green5
        }
        
        colorView.backgroundColor = backgroundColor
        
        addSubview(colorView)
        
        colorView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalToSuperview().inset(5)
        }
    }
}
