import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subject, takeUntil } from 'rxjs';
import { AuthService, User } from '../../core/services/auth.service';

@Component({
  selector: 'app-tasks-overview',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="module-container">
      <div class="module-header">
        <h1>✔️ My Tasks</h1>
        <p class="subtitle">View and manage your assigned tasks</p>
      </div>

      <div class="placeholder-content">
        <div class="placeholder-card">
          <h2>📋 Task Overview</h2>
          <div class="task-stats">
            <div class="stat-box pending">
              <div class="stat-value">--</div>
              <div class="stat-label">Pending Tasks</div>
            </div>
            <div class="stat-box in-progress">
              <div class="stat-value">--</div>
              <div class="stat-label">In Progress</div>
            </div>
            <div class="stat-box completed">
              <div class="stat-value">--</div>
              <div class="stat-label">Completed</div>
            </div>
          </div>
        </div>

        <div class="placeholder-card coming-soon">
          <h2>🚧 Coming Soon</h2>
          <p>Task Management module is under development.</p>
          <div class="feature-list">
            <ul>
              <li>Personal task tracking</li>
              <li *ngIf="hasRole('Manager')">Team task assignment</li>
              <li *ngIf="hasRole('Admin')">System-wide task overview</li>
              <li>Task filtering and sorting</li>
              <li>Task deadlines and reminders</li>
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

    .task-stats {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 1rem;
      margin-top: 1.5rem;
    }

    .stat-box {
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
        font-weight: 500;
      }
      
      &.pending {
        background: #fef3c7;
        color: #d97706;
      }
      
      &.in-progress {
        background: #dbeafe;
        color: #2563eb;
      }
      
      &.completed {
        background: #d1fae5;
        color: #059669;
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
export class TasksOverviewComponent implements OnInit, OnDestroy {
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

