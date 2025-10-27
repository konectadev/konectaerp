import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subject, takeUntil } from 'rxjs';
import { AuthService, User } from '../../core/services/auth.service';

@Component({
  selector: 'app-hr-overview',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="module-container">
      <div class="module-header">
        <h1>👥 HR Management</h1>
        <p class="subtitle">Role-based access control in place</p>
      </div>

      <div class="access-info" *ngIf="currentUser">
        <div class="info-badge">
          <span class="label">Current User:</span>
          <span class="value">{{ currentUser.firstName }} {{ currentUser.lastName }}</span>
        </div>
        <div class="info-badge">
          <span class="label">Roles:</span>
          <span class="value">{{ currentUser.roles.join(', ') }}</span>
        </div>
      </div>

      <div class="placeholder-content">
        <div class="placeholder-card admin-only" *ngIf="hasRole('Admin')">
          <h2>🔧 Admin Functions</h2>
          <p>Full administrative access to HR management features.</p>
          <ul>
            <li>Manage all employees</li>
            <li>Create and assign roles</li>
            <li>Manage departments</li>
            <li>System configuration</li>
          </ul>
        </div>

        <div class="placeholder-card manager-only" *ngIf="hasRole('Manager')">
          <h2>📊 Manager Functions</h2>
          <p>Department-level HR management access.</p>
          <ul>
            <li>View department employees</li>
            <li>Approve leave requests</li>
            <li>Generate team reports</li>
            <li>Manage schedules</li>
          </ul>
        </div>

        <div class="placeholder-card coming-soon">
          <h2>🚧 Coming Soon</h2>
          <p>HR Management module is under development. This is a placeholder interface.</p>
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
      flex-wrap: wrap;
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
          border-bottom: 1px solid #f0f0f0;
          
          &:last-child {
            border-bottom: none;
          }
          
          &:before {
            content: '✓';
            color: #667eea;
            font-weight: bold;
            margin-right: 0.5rem;
          }
        }
      }
    }

    .coming-soon {
      background: linear-gradient(135deg, #f8f9ff 0%, #e8ebff 100%);
    }
  `]
})
export class HrOverviewComponent implements OnInit, OnDestroy {
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

