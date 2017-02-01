/*! React Starter Kit | MIT License | http://www.reactstarterkit.com/ */

import React from 'react';
import withScroll from '../../decorators/withViewportScroll';
// import NavMobile from '../NavMobile';
// import Logo from '../ui/Logo';

@withScroll
class Header extends React.Component {
    constructor(props) {
        super(props);
    }
    
    render() {
        let scrollTop = this.props.viewportScroll.top;
        if (scrollTop > 100 && scrollTop < 500) {
            if (this.props.viewportScroll.scrollDown) {
                var scrollHead = 'b-header__hideDown';
            }
            if (this.props.viewportScroll.scrollUp) {
                var scrollHead = 'b-header__hideUp';
            }
        }
        if (scrollTop > 500) {
            if (this.props.viewportScroll.scrollDown) {
                var scrollHead = 'b-header__ScrollDown';
            }
            if (this.props.viewportScroll.scrollUp) {
                var scrollHead = 'b-header__ScrollUp';
            }
        }
        
        return (
            <header className={`container__Header`}>
                <div className="Header">
                    
                    <div className="Header__logo">
                        <a className="Logo"
                           href="/"></a>
                    </div>
                    
                    
                    <div className="Header__nav-container">
                        <div className="nav">
                            <div className=""
                                 role="navigation">
                                <div className="b-nav"
                                     role="navigation">
                                    <a className="b-nav__link"
                                       href="/about">О компании</a>
                                    <a className="b-nav__link"
                                       href="/contact">Контакты</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="Header__info-container">
                        <div className="info">
                            
                            <div className="info__logo">
                                <a className="Logo"
                                   href="https://inna.ru/#/"></a>
                            </div>
                            
                            <div className="info_tel-login">
                                <div className="tel">
                                    <span className="tel__icon icon-emb-phone"></span>
                                    <div className="tel__number-time">
                                        <div className="number">+7 495 742-1212</div>
                                        <div className="time">круглосуточно</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </header>
        );
    }
    
}

export default Header;
