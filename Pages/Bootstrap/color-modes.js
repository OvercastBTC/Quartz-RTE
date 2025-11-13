/**
 * Bootstrap Color Modes JavaScript for Quartz RTE
 * Provides dark/light theme switching functionality
 */

class ColorModes {
  constructor() {
    this.storageKey = 'quartz-color-mode';
    this.themes = {
      light: {
        name: 'Light',
        class: 'light-mode',
        variables: {
          '--bg-color': '#ffffff',
          '--text-color': '#212529',
          '--border-color': '#dee2e6',
          '--primary-color': '#007bff',
          '--secondary-color': '#6c757d'
        }
      },
      dark: {
        name: 'Dark',
        class: 'dark-mode',
        variables: {
          '--bg-color': '#212529',
          '--text-color': '#ffffff',
          '--border-color': '#495057',
          '--primary-color': '#0d6efd',
          '--secondary-color': '#adb5bd'
        }
      },
      auto: {
        name: 'Auto',
        class: 'auto-mode'
      }
    };
    this.currentTheme = this.getStoredTheme() || 'auto';
    this.init();
  }

  init() {
    this.applyTheme(this.currentTheme);
    this.createThemeToggle();
    this.bindEvents();
  }

  createThemeToggle() {
    // Check if theme toggle already exists
    if (document.querySelector('.theme-toggle')) {
      return;
    }

    const toggle = document.createElement('div');
    toggle.className = 'theme-toggle';
    toggle.innerHTML = `
      <button class="btn-theme-toggle" title="Toggle theme">
        <svg class="theme-icon sun-icon" width="16" height="16" viewBox="0 0 16 16">
          <path d="M8 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM8 0a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 0zm0 13a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 13zm8-5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2a.5.5 0 0 1 .5.5zM3 8a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2A.5.5 0 0 1 3 8zm10.657-5.657a.5.5 0 0 1 0 .707l-1.414 1.414a.5.5 0 1 1-.707-.707l1.414-1.414a.5.5 0 0 1 .707 0zm-9.193 9.193a.5.5 0 0 1 0 .707L3.05 13.657a.5.5 0 0 1-.707-.707l1.414-1.414a.5.5 0 0 1 .707 0zm9.193 2.121a.5.5 0 0 1-.707 0l-1.414-1.414a.5.5 0 0 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .707zM4.464 4.465a.5.5 0 0 1-.707 0L2.343 3.05a.5.5 0 1 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .708z"/>
        </svg>
        <svg class="theme-icon moon-icon" width="16" height="16" viewBox="0 0 16 16">
          <path d="M6 .278a.768.768 0 0 1 .08.858 7.208 7.208 0 0 0-.878 3.46c0 4.021 3.278 7.277 7.318 7.277.527 0 1.04-.055 1.533-.16a.787.787 0 0 1 .81.316.733.733 0 0 1-.031.893A8.349 8.349 0 0 1 8.344 16C3.734 16 0 12.286 0 7.71 0 4.266 2.114 1.312 5.124.06A.752.752 0 0 1 6 .278z"/>
        </svg>
      </button>
    `;

    // Add CSS for theme toggle
    const style = document.createElement('style');
    style.textContent = `
      .theme-toggle {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 1050;
      }
      .btn-theme-toggle {
        background: var(--bg-color, #ffffff);
        border: 1px solid var(--border-color, #dee2e6);
        border-radius: 0.25rem;
        padding: 0.375rem;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.15s ease;
      }
      .btn-theme-toggle:hover {
        background: var(--primary-color, #007bff);
        color: white;
      }
      .theme-icon {
        fill: currentColor;
      }
      .light-mode .moon-icon,
      .dark-mode .sun-icon {
        display: none;
      }
    `;
    document.head.appendChild(style);

    // Add to document
    document.body.appendChild(toggle);
  }

  bindEvents() {
    const toggleButton = document.querySelector('.btn-theme-toggle');
    if (toggleButton) {
      toggleButton.addEventListener('click', () => {
        this.cycleTheme();
      });
    }

    // Listen for system theme changes
    if (window.matchMedia) {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
      mediaQuery.addEventListener('change', () => {
        if (this.currentTheme === 'auto') {
          this.applyTheme('auto');
        }
      });
    }
  }

  cycleTheme() {
    const themes = Object.keys(this.themes);
    const currentIndex = themes.indexOf(this.currentTheme);
    const nextIndex = (currentIndex + 1) % themes.length;
    this.setTheme(themes[nextIndex]);
  }

  setTheme(themeName) {
    if (!this.themes[themeName]) {
      themeName = 'auto';
    }
    this.currentTheme = themeName;
    this.applyTheme(themeName);
    this.storeTheme(themeName);
  }

  applyTheme(themeName) {
    const theme = this.themes[themeName];
    const root = document.documentElement;
    
    // Remove all theme classes
    Object.values(this.themes).forEach(t => {
      if (t.class) {
        root.classList.remove(t.class);
      }
    });

    if (themeName === 'auto') {
      // Use system preference
      const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      const actualTheme = prefersDark ? this.themes.dark : this.themes.light;
      
      if (actualTheme.class) {
        root.classList.add(actualTheme.class);
      }
      
      if (actualTheme.variables) {
        Object.entries(actualTheme.variables).forEach(([prop, value]) => {
          root.style.setProperty(prop, value);
        });
      }
    } else {
      // Use specific theme
      if (theme.class) {
        root.classList.add(theme.class);
      }
      
      if (theme.variables) {
        Object.entries(theme.variables).forEach(([prop, value]) => {
          root.style.setProperty(prop, value);
        });
      }
    }

    // Update Quill theme if available
    if (window.quill) {
      this.updateQuillTheme(themeName);
    }
  }

  updateQuillTheme(themeName) {
    const toolbar = document.querySelector('.ql-toolbar');
    const editor = document.querySelector('.ql-editor');
    
    if (toolbar && editor) {
      if (themeName === 'dark' || (themeName === 'auto' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
        toolbar.style.backgroundColor = '#343a40';
        toolbar.style.borderColor = '#495057';
        editor.style.backgroundColor = '#212529';
        editor.style.color = '#ffffff';
      } else {
        toolbar.style.backgroundColor = '';
        toolbar.style.borderColor = '';
        editor.style.backgroundColor = '';
        editor.style.color = '';
      }
    }
  }

  getStoredTheme() {
    return localStorage.getItem(this.storageKey);
  }

  storeTheme(themeName) {
    localStorage.setItem(this.storageKey, themeName);
  }

  getCurrentTheme() {
    return this.currentTheme;
  }
}

// Initialize color modes when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  window.colorModes = new ColorModes();
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ColorModes;
}