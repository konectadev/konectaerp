import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subject, takeUntil } from 'rxjs';
import { AuthService, User } from '../../core/services/auth.service';

@Component({
  selector: 'app-finance-overview',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="module-container">
      <div class="module-header">
        <h1>💰 Finance Management</h1>
        <p class="subtitle">Financial tracking and reporting</p>
      </div>

      <div class="access-info" *ngIf="currentUser">
        <div class="info-badge">
          <span class="label">Access Level:</span>
          <span class="value">{{ hasRole('Admin') ? 'Full Access' : hasRole('Manager') ? 'Department Access' : 'View Only' }}</span>
        </div>
      </div>

      <div class="placeholder-content">
        <div class="placeholder-card" *ngIf="hasRole('Admin') || hasRole('Manager')">
          <h2>📊 Financial Overview</h2>
          <div class="stats-grid">
            <div class="stat-box">
              <div class="stat-value">$--</div>
              <div class="stat-label">Total Revenue</div>
            </div>
            <div class="stat-box">
              <div class="stat-value">$--</div>
              <div class="stat-label">Monthly Expenses</div>
            </div>
            <div class="stat-box">
              <div class="stat-value">$--</div>
              <div class="stat-label">Profit Margin</div>
            </div>
          </div>
        </div>

        <div class="placeholder-card">
          <h2>🚧 Coming Soon</h2>
          <p>Finance Management module is under development.</p>
          <div *ngIf="hasRole('Admin')" class="feature-list">
            <h3>Admin Features:</h3>
            <ul>
              <li>Full financial reporting</li>
              <li>Budget management</li>
              <li>Expense approval</li>
              <li>Revenue tracking</li>
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

    .access-info {
      display: flex;
      gap: 1rem;
      margin-bottom: 2rem;
    }

    .info-badge {
      background: #f8f9ff;
      padding: 0.75rem 1.25rem;
      border-radius: 8px;
      border: 1px solid #e1e5e9;
      display: flex;
      gap: 0.5rem;
      
      .label {
        font-weight: 600;
        color: #666;
      }
      
      .value {
        color: #667eea;
        font-weight: 500;
      }
    }

    .placeholder-content {
      display: grid;
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
      
      ul {
        list-style: none;
        padding: 0;
        
        li {
          padding: 0.5rem 0;
          color: #555;
          
          &:before {
            content: '✓';
            color: #667eea;
            margin-right: 0.5rem;
          }
        }
      }
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1.5rem;
      margin-top: 1.5rem;
    }

    .stat-box {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 1.5rem;
      border-radius: 12px;
      text-align: center;
      
      .stat-value {
        font-size: 2rem;
        font-weight: 700;
        margin-bottom: 0.5rem;
      }
      
      .stat-label {
        font-size: 0.875rem;
        opacity: 0.9;
      }
    }

    .feature-list {
      margin-top: 1.5rem;
      padding-top: 1.5rem;
      border-top: 1px solid #e1e5e9;
      
      h3 {
        color: #333;
        margin-bottom: 1rem;
      }
    }
  `]
})
export class FinanceOverviewComponent implements OnInit, OnDestroy {
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

