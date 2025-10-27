import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subject, takeUntil } from 'rxjs';
import { AuthService, User } from '../../core/services/auth.service';

@Component({
  selector: 'app-inventory-overview',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="module-container">
      <div class="module-header">
        <h1>📦 Inventory Management</h1>
        <p class="subtitle">Track and manage your inventory</p>
      </div>

      <div class="placeholder-content">
        <div class="placeholder-card">
          <h2>🛍️ Inventory Overview</h2>
          <div class="info-box">
            <div class="info-item">
              <span class="label">Total Items:</span>
              <span class="value">--</span>
            </div>
            <div class="info-item">
              <span class="label">Low Stock Items:</span>
              <span class="value">--</span>
            </div>
            <div class="info-item">
              <span class="label">Total Value:</span>
              <span class="value">$--</span>
            </div>
          </div>
        </div>

        <div class="placeholder-card coming-soon">
          <h2>🚧 Coming Soon</h2>
          <p>Inventory Management module is under development.</p>
          <div class="feature-list">
            <ul>
              <li>Product catalog management</li>
              <li>Stock level tracking</li>
              <li>Supplier management</li>
              <li *ngIf="hasRole('Admin')">Warehouse configuration</li>
              <li *ngIf="hasRole('Admin') || hasRole('Manager')">Inventory reports</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .module-container {
      max-width: 1200px;
      margin: 0 auto;
    }

    .module-header {
      margin-bottom: 2rem;
      
      h1 {
        font-size: 2.5rem;
        color: #333;
        margin-bottom: 0.5rem;
      }
      
      .subtitle {
        color: #666;
        font-size: 1.1rem;
      }
    }

    .placeholder-content {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
      gap: 1.5rem;
    }

    .placeholder-card {
      background: white;
      border: 1px solid #e1e5e9;
      border-radius: 12px;
      padding: 2rem;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      
      h2 {
        color: #333;
        margin-bottom: 1rem;
        font-size: 1.5rem;
      }
      
      p {
        color: #666;
        margin-bottom: 1rem;
      }
    }

    .coming-soon {
      background: linear-gradient(135deg, #f8f9ff 0%, #e8ebff 100%);
    }

    .info-box {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      margin-top: 1.5rem;
    }

    .info-item {
      display: flex;
      justify-content: space-between;
      padding: 1rem;
      background: #f8f9ff;
      border-radius: 8px;
      
      .label {
        font-weight: 600;
        color: #666;
      }
      
      .value {
        font-weight: 700;
        color: #667eea;
        font-size: 1.2rem;
      }
    }

    .feature-list {
      margin-top: 1.5rem;
      padding-top: 1.5rem;
      border-top: 1px solid #e1e5e9;
      
      ul {
        list-style: none;
        padding: 0;
        
        li {
          padding: 0.5rem 0;
          color: #555;
          
          &:before {
            content: '✓';
            color: #667eea;
            font-weight: bold;
            margin-right: 0.5rem;
          }
        }
      }
    }
  `]
})
export class InventoryOverviewComponent implements OnInit, OnDestroy {
  currentUser: User | null = null;
  private destroy$ = new Subject<void>();

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.authService.currentUser$
      .pipe(takeUntil(this.destroy$))
      .subscribe(user => this.currentUser = user);
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  hasRole(role: string): boolean {
    return this.authService.hasRole(role);
  }
}

