import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subject, takeUntil } from 'rxjs';
import { AuthService, User } from '../../core/services/auth.service';

@Component({
  selector: 'app-reports-overview',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="module-container">
      <div class="module-header">
        <h1>📊 Reports & Analytics</h1>
        <p class="subtitle">Generate and view system reports</p>
      </div>

      <div class="access-info" *ngIf="currentUser">
        <div class="info-badge">
          <span class="label">Access:</span>
          <span class="value">Reports & Analytics</span>
        </div>
      </div>

      <div class="placeholder-content">
        <div class="placeholder-card">
          <h2>📈 Available Reports</h2>
          <div class="reports-list">
            <div class="report-item" *ngIf="hasRole('Admin')">
              <span class="report-icon">📊</span>
              <div class="report-info">
                <h3>System Reports</h3>
                <p>Complete system analytics and metrics</p>
              </div>
            </div>
            <div class="report-item" *ngIf="hasRole('Admin') || hasRole('Manager')">
              <span class="report-icon">👥</span>
              <div class="report-info">
                <h3>Department Reports</h3>
                <p>Team performance and statistics</p>
              </div>
            </div>
            <div class="report-item">
              <span class="report-icon">💼</span>
              <div class="report-info">
                <h3>Activity Reports</h3>
                <p>User activity and engagement</p>
              </div>
            </div>
          </div>
        </div>

        <div class="placeholder-card coming-soon">
          <h2>🚧 Coming Soon</h2>
          <p>Reports module is under development.</p>
          <div class="feature-list">
            <ul>
              <li>Custom report builder</li>
              <li>Export to PDF/Excel</li>
              <li>Scheduled reports</li>
              <li *ngIf="hasRole('Admin')">Advanced analytics dashboard</li>
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
        margin-bottom: 1.5rem;
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

    .reports-list {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    .report-item {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1.25rem;
      background: #f8f9ff;
      border-radius: 8px;
      border: 1px solid #e1e5e9;
      transition: all 0.2s ease;
      
      &:hover {
        transform: translateX(4px);
        border-color: #667eea;
      }
      
      .report-icon {
        font-size: 2rem;
      }
      
      .report-info {
        flex: 1;
        
        h3 {
          margin: 0 0 0.25rem 0;
          color: #333;
          font-size: 1rem;
        }
        
        p {
          margin: 0;
          color: #666;
          font-size: 0.875rem;
        }
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
export class ReportsOverviewComponent implements OnInit, OnDestroy {
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

