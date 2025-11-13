/**
 * Bootstrap Sidebars JavaScript for Quartz RTE
 * Provides sidebar functionality and navigation
 */

class Sidebars {
  constructor() {
    this.sidebar = null;
    this.overlay = null;
    this.toggleButtons = [];
    this.isOpen = false;
    this.init();
  }

  init() {
    // Create sidebar elements if they don't exist
    this.createSidebar();
    this.bindEvents();
  }

  createSidebar() {
    // Check if sidebar already exists
    if (document.querySelector('.sidebar')) {
      this.sidebar = document.querySelector('.sidebar');
      this.overlay = document.querySelector('.sidebar-overlay');
      return;
    }

    // Create sidebar
    this.sidebar = document.createElement('div');
    this.sidebar.className = 'sidebar';
    this.sidebar.innerHTML = `
      <div class="sidebar-header">
        <h5 class="sidebar-title">Navigation</h5>
        <button class="sidebar-close" type="button">×</button>
      </div>
      <nav class="sidebar-nav">
        <ul class="sidebar-nav-list">
          <li class="sidebar-nav-item">
            <a href="#" class="sidebar-nav-link" data-action="new">New Document</a>
          </li>
          <li class="sidebar-nav-item">
            <a href="#" class="sidebar-nav-link" data-action="open">Open File</a>
          </li>
          <li class="sidebar-nav-item">
            <a href="#" class="sidebar-nav-link" data-action="save">Save Document</a>
          </li>
          <li class="sidebar-nav-item">
            <a href="#" class="sidebar-nav-link" data-action="export">Export HTML</a>
          </li>
          <li class="sidebar-nav-item">
            <a href="#" class="sidebar-nav-link" data-action="settings">Settings</a>
          </li>
        </ul>
      </nav>
    `;

    // Create overlay
    this.overlay = document.createElement('div');
    this.overlay.className = 'sidebar-overlay';

    // Add to document
    document.body.appendChild(this.sidebar);
    document.body.appendChild(this.overlay);
  }

  bindEvents() {
    // Toggle buttons
    this.toggleButtons = document.querySelectorAll('.sidebar-toggle');
    this.toggleButtons.forEach(button => {
      button.addEventListener('click', () => this.toggle());
    });

    // Close button
    const closeButton = this.sidebar.querySelector('.sidebar-close');
    if (closeButton) {
      closeButton.addEventListener('click', () => this.close());
    }

    // Overlay click to close
    this.overlay.addEventListener('click', () => this.close());

    // Navigation links
    const navLinks = this.sidebar.querySelectorAll('.sidebar-nav-link');
    navLinks.forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const action = link.getAttribute('data-action');
        this.handleNavigation(action);
      });
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.isOpen) {
        this.close();
      }
    });
  }

  open() {
    this.sidebar.classList.add('show');
    this.overlay.classList.add('show');
    this.isOpen = true;
    document.body.style.overflow = 'hidden';
  }

  close() {
    this.sidebar.classList.remove('show');
    this.overlay.classList.remove('show');
    this.isOpen = false;
    document.body.style.overflow = '';
  }

  toggle() {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }

  handleNavigation(action) {
    switch (action) {
      case 'new':
        if (window.newFile) {
          window.newFile();
        } else if (window.ahk && window.ahk.newFile) {
          window.ahk.newFile();
        }
        break;
      case 'open':
        if (window.openFile) {
          window.openFile();
        } else if (window.ahk && window.ahk.OpenFile) {
          window.ahk.OpenFile();
        }
        break;
      case 'save':
        if (window.saveFile) {
          window.saveFile();
        } else if (window.ahk && window.ahk.SaveFile) {
          window.ahk.SaveFile();
        }
        break;
      case 'export':
        if (window.passHTML) {
          window.passHTML();
        } else if (window.ahk && window.ahk.getHTML) {
          window.ahk.getHTML();
        }
        break;
      case 'settings':
        alert('Settings functionality would be implemented here');
        break;
    }
    this.close();
  }
}

// Initialize sidebar when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  window.sidebarManager = new Sidebars();
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = Sidebars;
}