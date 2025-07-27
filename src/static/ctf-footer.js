/**
 * CTF Footer Component
 * Adds CTF information and agreement status to all pages
 */

(function() {
    'use strict';
    
    // Check if user has agreed to rules
    function hasUserAgreed() {
        const localStorageAgreed = localStorage.getItem('agreedToRules') === 'yes';
        const cookieAgreed = document.cookie
            .split('; ')
            .find(row => row.startsWith('agreedToRules='))
            ?.split('=')[1] === 'yes';
        return localStorageAgreed || cookieAgreed;
    }
    
    // Create CTF footer HTML
    function createCTFFooter() {
        const agreed = hasUserAgreed();
        const agreementStatus = agreed ? 
            '<span style="color: #00ff88;">✓ Agreement Active</span>' : 
            '<span style="color: #ff6464;">⚠ No Agreement</span>';
        
        return `
            <div id="ctf-footer" style="
                background: linear-gradient(135deg, #0a0a0a 0%, #1a1a2e 100%);
                border-top: 3px solid #00ff88;
                color: #00ff88;
                font-family: 'Courier New', monospace;
                font-weight: bold;
                padding: 20px;
                text-align: center;
                position: relative;
                z-index: 1000;
                box-shadow: 0 -5px 20px rgba(0, 255, 136, 0.3);
            ">
                <div style="max-width: 1200px; margin: 0 auto;">
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px;">
                        <div style="flex: 1; min-width: 300px;">
                            <div style="font-size: 18px; margin-bottom: 10px; text-shadow: 0 0 10px rgba(0, 255, 136, 0.8);">
                                🎯 OWASP AGENTIC AI CTF DEMO
                            </div>
                            <div style="font-size: 14px; color: #cccccc;">
                                Educational AI Security Research Environment
                            </div>
                        </div>
                        
                        <div style="flex: 1; min-width: 250px;">
                            <div style="margin-bottom: 10px;">
                                <strong>Agreement Status:</strong> ${agreementStatus}
                            </div>
                            <div style="font-size: 12px; color: #cccccc;">
                                All activities monitored for educational purposes
                            </div>
                        </div>
                        
                        <div style="flex: 1; min-width: 200px;">
                            <a href="/entry.html" style="
                                background: linear-gradient(45deg, #00ff88, #00ccff);
                                color: #000;
                                text-decoration: none;
                                padding: 10px 20px;
                                border-radius: 5px;
                                font-weight: bold;
                                display: inline-block;
                                transition: all 0.3s ease;
                                box-shadow: 0 0 15px rgba(0, 255, 136, 0.4);
                            " onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 5px 25px rgba(0, 255, 136, 0.6)';" 
                               onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 0 15px rgba(0, 255, 136, 0.4)';">
                                🔍 CTF Details & Policy
                            </a>
                        </div>
                    </div>
                    
                    <div style="margin-top: 15px; padding-top: 15px; border-top: 1px solid #333; font-size: 12px; color: #888;">
                        <div style="display: flex; justify-content: center; gap: 30px; flex-wrap: wrap;">
                            <span>🛡️ Ethical Use Only</span>
                            <span>📊 Activities Logged</span>
                            <span>🎓 Educational Purpose</span>
                            <span>⚖️ OWASP Guidelines</span>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
    
    // Add footer to page
    function addCTFFooter() {
        // Don't add footer to entry page itself
        if (window.location.pathname.includes('entry.html') || window.location.pathname === '/entry') {
            return;
        }
        
        const footer = createCTFFooter();
        document.body.insertAdjacentHTML('beforeend', footer);
    }
    
    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', addCTFFooter);
    } else {
        addCTFFooter();
    }
    
    // Update footer when agreement status changes
    window.addEventListener('storage', function(e) {
        if (e.key === 'agreedToRules') {
            const existingFooter = document.getElementById('ctf-footer');
            if (existingFooter) {
                existingFooter.remove();
                addCTFFooter();
            }
        }
    });
    
})();

