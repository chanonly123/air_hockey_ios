//
//  ViewController.swift
//  TestCollision
//
//  Created by Chandan Karmakar on 16/04/18.
//  Copyright © 2018 StupidApp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    let color1 = UIColor.red
    let color2 = UIColor.blue
    
    var lblMiddle: UILabel!
    var lbl1: UILabel!
    var lbl2: UILabel!
    
    let strikerSize = 60
    let ballSize = 40
    var goalMargin = 50
    
    var striker1: BallView!
    var striker2: BallView!
    var ball: BallView!
    
    var animator: UIDynamicAnimator!
    var collision: UICollisionBehavior!
    var ballBehave: UIDynamicItemBehavior!
    var snap1: UISnapBehavior!
    var snap2: UISnapBehavior!
    
    var boardView: UIView!
    var player1SideView: UIView!
    var player2SideView: UIView!
    
    var collision1: UICollisionBehavior!
    var collision2: UICollisionBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add middle view
        lblMiddle = UILabel(frame: CGRect.zero)
        
        boardView = UIView(frame: CGRect(x: 0, y: -goalMargin, width: Int(view.frame.width), height: Int(view.frame.height) + (2 * goalMargin)))
        boardView.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        
        player1SideView = UIView(frame: CGRect(x: 0.0, y: CGFloat(goalMargin), width: view.frame.width, height: view.frame.height / 2))
        player1SideView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan1(_:))))
        player1SideView.isUserInteractionEnabled = true
        
        player2SideView = UIView(frame: CGRect(x: 0.0, y: view.frame.height / 2 + CGFloat(goalMargin), width: view.frame.width, height: view.frame.height / 2))
        player2SideView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan2(_:))))
        player2SideView.isUserInteractionEnabled = true
        
        lbl1 = UILabel(frame: CGRect.zero)
        lbl1.font = UIFont.boldSystemFont(ofSize: 120)
        lbl1.textColor = color1.withAlphaComponent(0.3)
        lbl1.textAlignment = .right
        lbl1.frame = player1SideView.frame.insetBy(dx: 20, dy: 0)
        
        lbl2 = UILabel(frame: CGRect.zero)
        lbl2.font = UIFont.boldSystemFont(ofSize: 120)
        lbl2.textColor = color2.withAlphaComponent(0.3)
        lbl2.textAlignment = .left
        lbl2.frame = player2SideView.frame.insetBy(dx: 20, dy: 0)
        
        striker1 = BallView(frame: CGRect(x: 0, y: 0, width: strikerSize, height: strikerSize))
        striker1.fillColor = color1
        striker1.center = player1SideView.center
        
        striker2 = BallView(frame: CGRect(x: 0, y: 0, width: strikerSize, height: strikerSize))
        striker2.fillColor = color2
        striker2.center = player2SideView.center
        
        ball = BallView(frame: CGRect(x: 0, y: 0, width: ballSize, height: ballSize))
        ball.fillColor = .black
        boardView.addSubview(ball)
        ball.center = CGPoint(x: boardView.frame.size.width / 2, y: boardView.frame.size.height / 2)
        
        view.addSubview(boardView)
        boardView.addSubview(lbl1)
        boardView.addSubview(lbl2)
        boardView.addSubview(striker1)
        boardView.addSubview(striker2)
        boardView.addSubview(player1SideView)
        boardView.addSubview(player2SideView)
        view.addSubview(lblMiddle)
        
        lblMiddle.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        lblMiddle.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        animateMiddleLabel(hide: true)
        
        lbl1.text = "0"
        lbl2.text = "0"
        
        
        addAllBehaviours()
    }
    
    func addAllBehaviours() {
        
        animator = UIDynamicAnimator(referenceView: boardView)
        
        collision = UICollisionBehavior(items: [striker1, striker2])
        collision.collisionDelegate = self
        collision.addItem(ball)
        collision.addBoundary(withIdentifier: "side_top".nsCopying, from: boardView.bounds.origin, to: boardView.bounds.topRight)
        collision.addBoundary(withIdentifier: "side_left".nsCopying, from: boardView.bounds.origin, to: boardView.bounds.botLeft)
        collision.addBoundary(withIdentifier: "side_right".nsCopying, from: boardView.bounds.topRight, to: boardView.bounds.end)
        collision.addBoundary(withIdentifier: "side_bot".nsCopying, from: boardView.bounds.botLeft, to: boardView.bounds.end)
        
        collision1 = UICollisionBehavior(items: [striker1])
        collision1.collisionMode = .boundaries
        collision1.addBoundary(withIdentifier: "col1".nsCopying, for: UIBezierPath(rect: player1SideView.frame))
        
        collision2 = UICollisionBehavior(items: [striker2])
        collision2.collisionMode = .boundaries
        collision2.addBoundary(withIdentifier: "col2".nsCopying, for: UIBezierPath(rect: player2SideView.frame))
        
        ballBehave = UIDynamicItemBehavior(items: [ball])
        ballBehave.friction = 0.9
        ballBehave.elasticity = 1.0
        
        animator.addBehavior(collision2)
        animator.addBehavior(collision)
        animator.addBehavior(ballBehave)
        animator.addBehavior(collision1)
    }
    
    @objc func handlePan1(_ gesture: UIGestureRecognizer) {
        if animator == nil { return }
        if snap1 != nil {
            animator.removeBehavior(snap1)
        }
        let locTo = gesture.location(in: boardView)
        snap1 = UISnapBehavior(item: striker1, snapTo: locTo)
        animator.addBehavior(snap1)
    }
    
    @objc func handlePan2(_ gesture: UIGestureRecognizer) {
        if animator == nil { return }
        if snap2 != nil {
            animator.removeBehavior(snap2)
        }
        let locTo = gesture.location(in: boardView)
        snap2 = UISnapBehavior(item: striker2, snapTo: locTo)
        animator.addBehavior(snap2)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: UICollisionBehaviorDelegate
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if item === ball {
            if identifier?.string == "side_top" {
                print("Goal 1")
                endGame(win: 1)
            } else if identifier?.string == "side_bot" {
                print("Goal 2")
                endGame(win: 2)
            }
        }
    }
    
    func endGame(win: Int) {
        player1SideView.isUserInteractionEnabled = false
        player2SideView.isUserInteractionEnabled = false
        
        animator.removeAllBehaviors()
        animator = nil
        
        striker1.transform = CGAffineTransform.identity
        striker2.transform = CGAffineTransform.identity
        ball.transform = CGAffineTransform.identity

        ball.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        
        var lblAnim: UILabel!
        if win == 1 {
            lbl2.text = "\(Int(lbl2.text!)! + 1)"
            lblAnim = lbl2
        } else {
            lbl1.text = "\(Int(lbl1.text!)! + 1)"
            lblAnim = lbl1
        }
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
            lblAnim.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
                lblAnim.transform = CGAffineTransform.identity
            }, completion: nil)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.restartGame()
        }
    }
    
    func restartGame() {
        self.ball.center = CGPoint(x: self.boardView.frame.size.width / 2, y: self.boardView.frame.size.height / 2)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.striker1.center = self.player1SideView.center
            self.striker2.center = self.player2SideView.center
            self.ball.transform = CGAffineTransform.identity
        }) { fin in
            if !fin { return }
            self.player1SideView.isUserInteractionEnabled = true
            self.player2SideView.isUserInteractionEnabled = true
            self.addAllBehaviours()
        }
    }
    
    func animateMiddleLabel(hide: Bool, text: String? = nil) {
        lblMiddle.text = text
        let trans = hide ? CGAffineTransform(scaleX: 0.0, y: 0.0) : CGAffineTransform.identity
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.lblMiddle.transform = trans
        }, completion: nil)
    }
}

class BallView: UIView {
    
    var fillColor: UIColor = UIColor.black {
        didSet { setNeedsLayout() }
    }
    
    public override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .path
    }
    
    public override var collisionBoundingPath: UIBezierPath {
        let radius = min(bounds.size.width, bounds.size.height) / 2.0
        return UIBezierPath(arcCenter: CGPoint.zero, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
    }
    
    private var shapeLayer: CAShapeLayer!
    
    public override func layoutSubviews() {
        if shapeLayer == nil {
            shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = UIColor.clear.cgColor
            layer.addSublayer(shapeLayer)
        }
        
        let radius = min(bounds.size.width, bounds.size.height) / 2.0
        
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0), radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true).cgPath
    }
}

extension CGRect {
    
    var end: CGPoint {
        return CGPoint(x: origin.x + size.width, y: origin.y + size.height)
    }
    
    var topRight: CGPoint {
        return CGPoint(x: origin.x + size.width, y: origin.y)
    }
    
    var botLeft: CGPoint {
        return CGPoint(x: origin.x, y: origin.y + size.height)
    }
    
}

extension CGPoint {
    
    func offsetBy(x x_: CGFloat, y y_: CGFloat) -> CGPoint {
        return CGPoint(x: x + x_, y: y + y_)
    }
    
}

extension NSCopying {
    
    var string: String {
        return self as! String
    }
    
}

extension String {
    
    var nsCopying: NSCopying {
        return self as NSCopying
    }
    
}
